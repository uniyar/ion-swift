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

    /// Peer discovery closure
    public var onPeerDiscovered: PeerDiscoveredClosure?
    /// Peer removed closure
    public var onPeerRemoved: PeerRemovedClosure?

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
}

// MARK: RouterHandler protocol implementation

extension IONLocalPeer: RouterHandler {
    internal func didFindNode(_: Router, node: Node) {
        print("--- Local peer: didFindNode, ", node)
    }

    internal func didImproveRoute(_: Router, node: Node) {
        print("--- Local peer: didImproveRoute, ", node)
    }

    internal func didLoseNode(_: Router, node: Node) {
        print("--- Local peer: didLoseNode, ", node)
    }

    internal func handleConnection(_: Router,
                                   node: Node,
                                   connection: UnderlyingConnection) {
        print("--- Local peer: handleConnection, ", node, connection)
    }
}
