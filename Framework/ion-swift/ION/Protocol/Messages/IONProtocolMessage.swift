//
//  IONProtocolMessage.swift
//  ion-swift
//
//  Created by Ivan Manov on 08.03.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import Foundation

// Define the types of commands your ION will use.
enum IONMessageType: UInt32 {
    case invalid = 0
    case metrics = 1
    case core = 2

    var identifier: String {
        switch self {
        case .core:
            return "core"
        case .metrics:
            return "metrics"
        default:
            return "unk"
        }
    }
}
