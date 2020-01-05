//
//  IONAdvertiser.swift
//  ion-swift
//
//  Created by Ivan Manov on 05.01.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import Foundation

class IONAdvertiser: Advertiser {
    var isAdvertising: Bool = false

    var advertiserDelegate: AdvertiserDelegate?

    func startAdvertising(_: UUID) {}

    func stopAdvertising() {}
}
