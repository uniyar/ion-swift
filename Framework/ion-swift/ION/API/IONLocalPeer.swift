//
//  IONLocalPeer.swift
//  ion-swift
//
//  Created by Ivan Manov on 05.01.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import Network
import UIKit

public typealias PeersUpdateClosure = (_ peers: [IONRemotePeer]) -> Void
/// Used to notify about discovered peers.
public typealias PeerDiscoveredClosure = (_ peer: IONRemotePeer) -> Void
/// Used to notify about removed peers.
public typealias PeerRemovedClosure = (_ peer: IONRemotePeer) -> Void

public typealias ConnectionClosure = (_ peer: IONRemotePeer, _ connection: Connection) -> Void

/// A LocalPeer advertises the local peer in the network and browses for other peers.
/// It requires one or more Modules to accomplish this. Two Modules that come with Reto are the WlanModule and the RemoteP2P module.
/// The LocalPeer can also be used to establish multicast connections to multiple other peers.
public class IONLocalPeer {
    static var dafaultParemeters: NWParameters {
        return NWParameters(passcode: "ion") // NWParameters.defaultParams()
    }

    // MARK: Public properties

    /// This peer's name. If not specified in the constructor, it has a the device name.
    public let name: String
    /// Application identifier
    public let appId: String
    /// This peer's unique identifier. If not specified in the constructor, it has a random value.
    public let identifier: UUID
    /// The dispatch queue used to execute all networking operations and callbacks
    public let dispatchQueue: DispatchQueue
    /// Human readable device name
    public static var deviceName: String {
        return UIDevice.current.name
    }

    /// Available peers
    public var peers: [IONRemotePeer] = []
    public var connections: [Connection] = []

    /// Peers update closure
    public var onPeersUpdate: PeersUpdateClosure?
    /// Peer discovery closure
    public var onPeerDiscovered: PeerDiscoveredClosure?
    /// Peer removed closure
    public var onPeerRemoved: PeerRemovedClosure?
    var onConnection: ConnectionClosure?

    // MARK: Private properties

    /// ION router
    private let router: IONRouter

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
            module: ionModule
        )
        self.dispatchQueue = dispatchQueue

        self.dispatchQueue.async {
            self.router.delegate = self
        }
    }

    // MARK: Public methods

    /// This method starts the local peer. This will advertise the local peer in the network, starts browsing for other peers, and accepts incoming connections.
    /// - Parameters:
    ///   - onPeerDiscovered: Called when a peer is discovered.
    ///   - onPeerRemoved: Called when a peer is removed.
    ///   - onIncomingConnection: Called when a connection is available. Call accept on the peer to accept the connection.
    public func start() {
        self.startRouter()
    }

    /// Stops advertising and browsing.
    public func stop() {
        self.router.stop()
    }

    // MARK: Private methods

    /// Start ION router
    private func startRouter() {
        self.router.start()
    }

    // MARK: Private methods

    private func createPeer(with node: Node) -> IONRemotePeer {
        return IONRemotePeer(node: node, localPeer: self, dispatchQueue: self.dispatchQueue)
    }

    private func addPeer(with node: Node) {
        self.peers.removeAll(where: { $0.stringIdentifier == node.identifier.UUIDString })
        self.peers.append(self.createPeer(with: node))
        self.onPeersUpdate?(self.peers)
    }

    private func removePeer(with node: Node) {
        self.peers.removeAll(where: { $0.stringIdentifier == node.identifier.UUIDString })
        self.onPeersUpdate?(self.peers)
    }
}

// MARK: RouterHandler protocol implementation

extension IONLocalPeer: RouterHandler {
    internal func didFindNode(_: Router, node: Node) {
        print("--- Local peer: didFindNode, ", node)
        self.addPeer(with: node)
    }

    internal func didImproveRoute(_: Router, node: Node) {
        print("--- Local peer: didImproveRoute, ", node)
        self.addPeer(with: node)
    }

    internal func didLoseNode(_: Router, node: Node) {
        print("--- Local peer: didLoseNode, ", node)
        self.removePeer(with: node)
    }

    internal func handleConnection(_: Router,
                                   node: Node,
                                   connection: UnderlyingConnection) {
        print("--- Local peer: handleConnection, ", node, connection)
        _ = readSinglePacket(connection: connection, onPacket: { data in
            if let packet = ManagedConnectionHandshake.deserialize(data) {
                self.handleConnection(
                    node: node,
                    connection: connection,
                    connectionIdentifier: packet.connectionIdentifier
                )
            } else {
                log(.low, info: "Expected ManagedConnectionHandshake.")
            }
        }, onFail: {
            log(.high, info: "Connection closed before receiving ManagedConnectionHandshake")
        })
    }
}

// MARK: Remote peers connection methods / ConnectionManager protocol

extension IONLocalPeer: ConnectionManager {
    private func createConnection(peer: IONRemotePeer,
                                  connection: UnderlyingConnection,
                                  connectionIdentifier: UUID) {
        let packetConnection = PacketConnection(connection: connection,
                                                connectionIdentifier: connectionIdentifier,
                                                destinations: [peer.node])
        peer.connections[connectionIdentifier] = packetConnection

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
            log(.high, warning: "An incoming connection was received, but onConnection is not set. Set it either in your LocalPeer instance (\(self)), or in the RemotePeer which established the connection (\(peer)).")
        }
    }

    private func handleConnection(node: Node,
                                  connection: UnderlyingConnection,
                                  connectionIdentifier: UUID) {
        var remotePeer: IONRemotePeer!

        if let peer = self.peers.first(where: { $0.stringIdentifier == node.identifier.UUIDString }) {
            remotePeer = peer
        } else {
            remotePeer = self.createPeer(with: node)
            self.addPeer(with: node)
        }

        if let packetConnection = remotePeer.connections[connectionIdentifier] {
            packetConnection.swapUnderlyingConnection(connection)
        } else {
            self.createConnection(
                peer: remotePeer,
                connection: connection,
                connectionIdentifier: connectionIdentifier
            )
        }
    }

    internal func connect(_ destinations: Set<IONRemotePeer>) -> Connection {
        let destinations = Set(destinations.map { $0.node })
        let identifier = randomUUID()

        let packetConnection = PacketConnection(
            connection: nil,
            connectionIdentifier: identifier,
            destinations: destinations
        )

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

    // ConnectionManager protocol

    func establishUnderlyingConnection(_ packetConnection: PacketConnection) {
        self.router.establishMulticastConnection(
            destinations: packetConnection.destinations,
            onConnection: { connection in
                _ = writeSinglePacket(
                    connection: connection,
                    packet: ManagedConnectionHandshake(
                        connectionIdentifier: packetConnection.connectionIdentifier
                    ),
                    onSuccess: {
                        packetConnection.swapUnderlyingConnection(connection)
                    },
                    onFail: {
                        log(.medium, error: "Failed to send ManagedConnectionHandshake.")
                    }
                )
            }, onFail: {
                log(.medium, error: "Failed to establish connection.")
            }
        )
    }

    func notifyConnectionClose(_: PacketConnection) {}
}
