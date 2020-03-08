//
//  IONModule.swift
//  ion-swift
//
//  Created by Ivan Manov on 05.01.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import Foundation

class IONModule: Module {
    init(type prefix: String, dispatchQueue: DispatchQueue) {
        super.init(dispatchQueue: dispatchQueue)

        self.browser = IONBrowser(type: prefix, dispatchQueue: dispatchQueue)
        self.advertiser = IONAdvertiser(type: prefix, dispatchQueue: dispatchQueue)
    }
}
