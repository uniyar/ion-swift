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
            print("--- ion-swift-example. Peers update: ", peers.map { $0.stringIdentifier })
        }
    }
}
