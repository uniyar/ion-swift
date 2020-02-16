//
//  ViewController.swift
//  ion-swift-example
//
//  Created by Ivan Manov on 05.01.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import ion_swift
import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let localPeer = IONLocalPeer(appId: "example", dispatchQueue: .main)
        localPeer.start()

        localPeer.onPeersUpdate = { peers in
            print(
                "--- ion-swift-example. Peers update: ",
                peers.map { "\($0.name ?? "Unk"):\($0.stringIdentifier)" }
            )

            self.handlePeers(peers)
        }
    }

    func handlePeers(_ peers: [IONRemotePeer]) {
        if peers.count > 0, let peer = peers.first {
            peer.onConnection = { _, connection in
                connection.onData = { data in
                    print("Data received: ", String(data: data, encoding: .utf8) ?? "")
                }
            }

            self.sendTest(to: peer)
        }
    }

    func sendTest(to peer: IONRemotePeer) {
        let connection = peer.connect()
        let transfer = connection.send(data: "TEST".data(using: .utf8)!)
        transfer.onProgress = { transfer in
            let progress = (transfer.progress * 100) / transfer.length
            print("Progress: ", progress)
        }
        transfer.onEnd = { _ in
            print("Transfer ended")
        }
    }
}
