//
//  ComputationParameter.swift
//  ion-swift
//
//  Created by Ivan Manov on 16.02.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import Foundation

/// Computation efficiency parameter
struct ComputationParameter: MetricParameter {
    /// Current load of node / device
    /// Range: 0..1. Less is better.
    let load: Float
    /// Max target load based on metric rules
    /// Range: 0..1. Less is better.
    let maxLoad: Float

    // MARK: MetricParameter protocol

    let type: MetricParameterType = .computation

    var value: Float {
        if self.load < 0 || self.maxLoad <= 0 { return 0 }

        return 1 - (self.load / self.maxLoad)
    }
}
