//
//  IONConnection.swift
//  ion-swift
//
//  Created by Ivan Manov on 05.01.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import Foundation

class IONConnection: UnderlyingConnection {
    var delegate: UnderlyingConnectionDelegate?

    var isConnected: Bool = false
    var recommendedPacketSize: Int = 0

    func connect() {}

    func close() {}

    func writeData(_: Data) {}
}
