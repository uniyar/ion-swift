//
//  LossParameter.swift
//  ion-swift
//
//  Created by Ivan Manov on 15.02.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import Foundation

struct LossParameter: MetricParameter {
    /// Transmitted data amount
    let transmitted: UInt?
    /// Received data amount
    let received: UInt?
    /// Pre-calculated ratio value
    let ratio: Float?

    // MARK: MetricParameter protocol

    let type: MetricParameterType = .loss

    var value: Float {
        if let received = self.received,
            let transmitted = self.transmitted, transmitted > 0 {
            return Float(received) / Float(transmitted)
        }

        if let ratio = self.ratio, 0 ... 1 ~= ratio {
            return ratio
        }

        return 0
    }
}
