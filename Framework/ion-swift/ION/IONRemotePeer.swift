//
//  IONRemotePeer.swift
//  ion-swift
//
//  Created by Ivan Manov on 06.01.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import Foundation

/// A RemotePeer represents another peer in the network.
/// You do not construct RemotePeer instances yourself, they are provided to you by the LocalPeer.
/// This class can be used to establish and accept connections to/from those peers.
public class IONRemotePeer: NSObject {
    /// This peer's unique identifier.
    public let identifier: UUID
    /// This peer's name.
    public let name: String?
    /// Returns the UUID identifier as string to bridge to Objective-C Code
    public var stringIdentifier: String {
        return self.identifier.UUIDString
    }
    public var bestAddress: Address? {
        return self.node.bestAddress
    }
    public var addresses: [Address]? {
        return self.node.directAddresses
    }
    public var isNeighbor: Bool {
        return self.node.isNeighbor
    }
    public var isReachable: Bool {
        return self.node.isReachable
    }

    /// Set this property if you want to handle incoming connections on a per-peer basis.
    public var onConnection: ConnectionClosure?
    /// Establishes a connection to this peer.
    public func connect() -> Connection {
        return self.localPeer.connect([self])
    }

    // MARK: Internal

    /// The node representing this peer on the routing level
    let node: Node
    /// The LocalPeer that created this peer
    let localPeer: IONLocalPeer
    /// Stores all connections established by this peer
    internal var connections: [UUID: PacketConnection] = [:]

    /**
     * Private initializer. See the class documentation about how to obtain RemotePeer instances.
     * @param node The node representing the the peer on the routing level.
     * @param localPeer The local peer that created this peer
     */
    init(node: Node, localPeer: IONLocalPeer, dispatchQueue _: DispatchQueue) {
        self.node = node
        self.localPeer = localPeer
        self.identifier = node.identifier
        self.name = node.name
    }
}
