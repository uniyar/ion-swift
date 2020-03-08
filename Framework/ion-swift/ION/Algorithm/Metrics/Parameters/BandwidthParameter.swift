//
//  BandwidthParameter.swift
//  ion-swift
//
//  Created by Ivan Manov on 15.02.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import Foundation

/// Efficient bandwidth available parameter
struct BandwidthParameter: MetricParameter {
    /// Current efficient bandwidth on connection
    /// Range: 0..Inf. In megabits. More is better.
    let bandwidth: Float
    /// Max target bandwidth based on metric rules
    let maxBandwidth: Float

    // MARK: MetricParameter protocol

    let type: MetricParameterType = .bandwidth

    /// Calculates based on max allocated bandwidth during the last connection probe
    var value: Float {
        if self.bandwidth < 0 || self.maxBandwidth <= 0 { return 0 }

        return self.bandwidth / self.maxBandwidth
    }
}
