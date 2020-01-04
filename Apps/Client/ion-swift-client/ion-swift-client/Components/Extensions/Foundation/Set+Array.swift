//
//  Set+Array.swift
//  ion-swift-client
//
//  Created by Ivan Manov on 26.12.2019.
//  Copyright © 2019 kxpone. All rights reserved.
//

import Foundation

extension Set {
    var array: [Element] {
        return Array(self)
    }
}
