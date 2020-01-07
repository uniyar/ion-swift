//
//  IONLocalPeer.swift
//  ion-swift
//
//  Created by Ivan Manov on 05.01.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import Network
import UIKit

/// Used to notify about discovered peers.
public typealias PeerDiscoveredClosure = (_ peer: IONRemotePeer) -> Void
/// Used to notify about removed peers.
public typealias PeerRemovedClosure = (_ peer: IONRemotePeer) -> Void
/// Used to notify about incoming connections peers.
public typealias ConnectionClosure = (_ peer: IONRemotePeer, _ connection: Connection) -> Void

/// A LocalPeer advertises the local peer in the network and browses for other peers.
/// It requires one or more Modules to accomplish this. Two Modules that come with Reto are the WlanModule and the RemoteP2P module.
/// The LocalPeer can also be used to establish multicast connections to multiple other peers.
public class IONLocalPeer {
    // MARK: Public properties

    static var dafaultParemeters: NWParameters {
        return NWParameters(passcode: "ion")
    }

    /// This peer's name. If not specified in the constructor, it has a the device name.
    public let name: String
    /// Application identifier
    public let appId: String
    /// This peer's unique identifier. If not specified in the constructor, it has a random value.
    public let identifier: UUID
    /// The dispatch queue used to execute all networking operations and callbacks
    public let dispatchQueue: DispatchQueue
    /// The set of peers currently reachable
    open var peers: Set<IONRemotePeer> {
        return Set(knownPeers.values)
    }

    public static var deviceName: String {
        return UIDevice.current.name
    }

    // MARK: Internal and Private properties

    private var onPeerDiscovered: PeerDiscoveredClosure?
    private var onPeerRemoved: PeerRemovedClosure?
    var onConnection: ConnectionClosure?

    private let router: IONRouter
    private var knownPeers = [Node: IONRemotePeer]()
    private var establishedConnections = [UUID: PacketConnection]()
    private var incomingConnections = [UUID: PacketConnection]()

    // MARK: Initialization methods

    /// Constructs a new LocalPeer object. A vendor identifier will be used for the LocalPeer.
    /// - Parameters:
    ///   - appId: The application identifier used for the same application peers discovery
    ///   - name: The name used for the peer
    ///   - identifier: The identifier used for the peer
    ///   - dispatchQueue: The dispatchQueue used to run all networking code with. The dispatchQueue can be used to specifiy the thread that should be used.
    public init(appId: String = "default_ion_app",
                name: String = IONLocalPeer.deviceName,
                identifier: UUID = vendorUUID(),
                dispatchQueue: DispatchQueue = .main) {
        self.name = name
        self.appId = appId
        self.identifier = identifier

        let ionModule = IONModule(type: appId, dispatchQueue: dispatchQueue)

        self.router = IONRouter(
            localIdentifier: identifier,
            localName: name,
            dispatchQueue: dispatchQueue,
            modules: [ionModule]
        )
        self.dispatchQueue = dispatchQueue

        self.dispatchQueue.async {
            self.router.delegate = self
        }
    }

    /// This method starts the local peer. This will advertise the local peer in the network, starts browsing for other peers, and accepts incoming connections.
    /// - Parameters:
    ///   - onPeerDiscovered: Called when a peer is discovered.
    ///   - onPeerRemoved: Called when a peer is removed.
    ///   - onIncomingConnection: Called when a connection is available. Call accept on the peer to accept the connection.
    open func start(onPeerDiscovered: @escaping PeerDiscoveredClosure,
                    onPeerRemoved: @escaping PeerRemovedClosure,
                    onIncomingConnection: @escaping ConnectionClosure) {
        self.onPeerDiscovered = onPeerDiscovered
        self.onPeerRemoved = onPeerRemoved
        self.onConnection = onIncomingConnection

        self.startRouter()
    }

    /// Stops advertising and browsing.
    open func stop() {
        self.router.stop()

        self.onPeerDiscovered = nil
        self.onPeerRemoved = nil
        self.onConnection = nil
    }

    /// Add a module to this LocalPeer. The module will be started immediately if the LocalPeer is already started.
    /// - Parameter module: The module that should be added.
    open func addModule(_ module: Module) {
        self.router.addModule(module)
    }

    /// Remove a module from this LocalPeer.
    /// - Parameter module: The module that should be removed.
    open func removeModule(_ module: Module) {
        self.router.addModule(module)
    }

    // MARK: Establishing multicast connections

    /// Establishes a multicast connection to a set of peers. The connection can only be used to send data, not to receive data.
    /// Returns a Connection object. It can be used to send data immediately (the transfers will be started once the connection was successfully established).
    /// - Parameter destinations: The IONRemotePeers to establish a connection with.
    open func connect(_ destinations: Set<IONRemotePeer>) -> Connection {
        let destinations = Set(destinations.map { $0.node })
        let identifier = randomUUID()
        let packetConnection = PacketConnection(connection: nil, connectionIdentifier: identifier, destinations: destinations)

        self.establishedConnections[identifier] = packetConnection

        let transferConnection = Connection(
            packetConnection: packetConnection,
            localIdentifier: self.identifier,
            dispatchQueue: self.dispatchQueue,
            isConnectionEstablisher: true,
            connectionManager: self
        )

        transferConnection.reconnect()

        return transferConnection
    }

    private func startRouter() {
        if self.router.modules.count == 0 {
            log(.high, warning: "You started the LocalPeer, but it does not have any modules. It cannot function without modules. See the LocalPeer class documentation for more information.")
        }

        self.router.start()
    }

    private func providePeer(_ node: Node) -> IONRemotePeer {
        return self.knownPeers.getOrDefault(
            node,
            defaultValue: IONRemotePeer(
                node: node,
                localPeer: self,
                dispatchQueue: self.dispatchQueue
            )
        )
    }

    /// Called when ManagedConnectionHandshake was received, i.e. when all necessary information is available to deal with this connection.
    /// If the corresponding PacketConnection already exists, its underlying connection is swapped. Otherwise, a new Connection is created.
    /// - Parameters:
    ///   - node: The node which established the connection
    ///   - connection:  The connection that was established
    ///   - connectionIdentifier: The identifier of the connection
    private func handleConnection(node: Node, connection: UnderlyingConnection, connectionIdentifier: UUID) {
        let needsToReportPeer = self.knownPeers[node] == nil

        let peer = self.providePeer(node)

        if needsToReportPeer {
            self.onPeerDiscovered?(peer)
        }

        if let packetConnection = peer.connections[connectionIdentifier] {
            packetConnection.swapUnderlyingConnection(connection)
        } else {
            self.createConnection(peer: peer, connection: connection, connectionIdentifier: connectionIdentifier)
        }
    }

    /// Creates a new connection and calls the handling closure.
    /// - Parameters:
    ///   - peer: peer description
    ///   - connection: connection description
    ///   - connectionIdentifier: connectionIdentifier description
    private func createConnection(
        peer: IONRemotePeer,
        connection: UnderlyingConnection,
        connectionIdentifier: UUID
    ) {
        let packetConnection = PacketConnection(
            connection: connection,
            connectionIdentifier: connectionIdentifier,
            destinations: [peer.node]
        )

        peer.connections[connectionIdentifier] = packetConnection

        self.incomingConnections[connectionIdentifier] = packetConnection

        let transferConnection = Connection(
            packetConnection: packetConnection,
            localIdentifier: self.identifier,
            dispatchQueue: self.dispatchQueue,
            isConnectionEstablisher: false,
            connectionManager: self
        )

        if let connectionClosure = peer.onConnection {
            connectionClosure(peer, transferConnection)
        } else if let connectionClosure = self.onConnection {
            connectionClosure(peer, transferConnection)
        } else {
            log(.high, warning: "An incoming connection was received, but onConnection is not set. Set it either in your LocalPeer instance (\(self)), or in the IONRemotePeer which established the connection (\(peer)).")
        }
    }

    /// <#Description#>
    /// - Parameter peer: <#peer description#>
    private func reconnect(_ peer: IONRemotePeer) {
        for (_, packetConnection) in self.establishedConnections {
            if packetConnection.destinations.contains(peer.node) {
                self.establishUnderlyingConnection(packetConnection)
            }
        }
    }
}

// MARK: RouterHandler protocol implementation

extension IONLocalPeer: RouterHandler {
    func didFindNode(_: Router, node: Node) {
        if self.knownPeers[node] != nil {
            return
        }

        let peer = providePeer(node)

        self.onPeerDiscovered?(peer)
    }

    func didImproveRoute(_: Router, node: Node) {
        self.reconnect(self.providePeer(node))
    }

    func didLoseNode(_: Router, node: Node) {
        let peer = providePeer(node)
        self.knownPeers[node] = nil
        peer.onConnection = nil

        self.onPeerRemoved?(peer)
    }

    /// Handles an incoming connection.
    /// - Parameters:
    ///   - router: The router which reported the connection
    ///   - node: The node which established the connection
    ///   - connection: The connection that was established
    internal func handleConnection(_: Router,
                                   node: Node,
                                   connection: UnderlyingConnection) {
        log(.high, info: "Handling incoming connection...")
        _ = readSinglePacket(connection: connection, onPacket: { data in
            if let packet = ManagedConnectionHandshake.deserialize(data) {
                self.handleConnection(node: node, connection: connection, connectionIdentifier: packet.connectionIdentifier)
            } else {
                log(.low, info: "Expected ManagedConnectionHandshake.")
            }
        }, onFail: {
            log(.high, info: "Connection closed before receiving ManagedConnectionHandshake")
        })
    }
}

// MARK: ConnectionManager protocol implementation

extension IONLocalPeer: ConnectionManager {
    func establishUnderlyingConnection(_ packetConnection: PacketConnection) {
        self.router.establishMulticastConnection(destinations: packetConnection.destinations, onConnection: { connection in
            _ = writeSinglePacket(connection: connection, packet: ManagedConnectionHandshake(connectionIdentifier: packetConnection.connectionIdentifier), onSuccess: {
                packetConnection.swapUnderlyingConnection(connection)
            },
                                  onFail: {
                log(.medium, error: "Failed to send ManagedConnectionHandshake.")
            })
        }, onFail: {
            log(.medium, error: "Failed to establish connection.")
        })
    }

    func notifyConnectionClose(_ connection: PacketConnection) {
        self.establishedConnections[connection.connectionIdentifier] = nil
        self.incomingConnections[connection.connectionIdentifier] = nil
    }
}
