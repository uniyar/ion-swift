//
//  IONManager.swift
//  ion-swift-client
//
//  Created by Ivan Manov on 23.12.2019.
//  Copyright © 2019 kxpone. All rights reserved.
//

import IONSwift
import RxSwift

class IONManager {
    static let shared = IONManager()

    private let disposeBag = DisposeBag()
    private let localPeer: IONLocalPeer

    let peersSubject = PublishSubject<[IONRemotePeer]>()
    var peers: [IONRemotePeer] {
        return self.localPeer.peers
    }

    private(set) var outgoingConnections = [String: Connection]()
    private(set) var incomingConnections = [String: Connection]()

    init() {
        self.localPeer = IONLocalPeer(
            appId: AppRepository.shared.appIdentifier,
            dispatchQueue: DispatchQueue.main
        )

        self.startION()
    }

    func connect(to peer: IONRemotePeer) -> Connection {
        if let connection = self.incomingConnections[peer.stringIdentifier] {
            if !connection.isConnected {
                self.incomingConnections[peer.stringIdentifier] = nil
            } else {
                return connection
            }
        }

        var connection = self.outgoingConnections[peer.stringIdentifier]
        if connection == nil {
            connection = peer.connect()
            self.outgoingConnections[peer.stringIdentifier] = connection
        }

        return connection!
    }

    private func startION() {
        localPeer.start()
        localPeer.onPeersUpdate = { peers in
            self.peersSubject.onNext(peers)
            print(peers.map { $0.stringIdentifier })
            self.handlePeers()
        }
    }

    private func handlePeers() {
        self.peers.forEach { peer in
            peer.onConnection = { peer, connection in
                self.incomingConnections[peer.stringIdentifier] = connection
            }
        }
    }
}
