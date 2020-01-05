//
//  IONAddress.swift
//  ion-swift
//
//  Created by Ivan Manov on 05.01.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import Foundation

class IONAddress: Address {
    var cost: Int = 0

    var hostName: String = ""

    func createConnection() -> UnderlyingConnection {
        return IONConnection()
    }
}
