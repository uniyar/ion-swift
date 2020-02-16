//
//  IONAddress.swift
//  ion-swift
//
//  Created by Ivan Manov on 05.01.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import Foundation
import Network

class IONAddress: Address {
    var cost: Int = 0
    var hostName: String = ""

    let endpoint: NWEndpoint
    let dispatchQueue: DispatchQueue

    init(hostName: String,
         endpoint: NWEndpoint,
         dispatchQueue: DispatchQueue) {
        self.hostName = hostName
        self.endpoint = endpoint
        self.dispatchQueue = dispatchQueue
    }

    func createConnection() -> UnderlyingConnection {
        return IONUnderlyingConnection(with: self.endpoint, dispatchQueue: self.dispatchQueue)
    }
}
