//
//  TimeParameter.swift
//  ion-swift
//
//  Created by Ivan Manov on 15.02.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import Foundation

struct TimeParameter: MetricParameter {
    /// Average delay on connection
    /// Range: 0..Inf. In milliseconds. Less is better.
    let delay: Float
    /// Max target delay based on metric rules
    let maxDelay: Float

    // MARK: MetricParameter

    let type: MetricParameterType = .time

    /// Calculated based on average delay of packet transmission during the connection probe
    var value: Float {
        if self.delay == 0, self.maxDelay == 0 { return 1 }
        if self.delay < 0 || self.maxDelay <= 0 { return 0 }

        return 1 - (self.delay / self.maxDelay)
    }
}
