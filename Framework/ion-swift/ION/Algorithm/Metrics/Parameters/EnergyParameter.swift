//
//  EnergyParameter.swift
//  ion-swift
//
//  Created by Ivan Manov on 16.02.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import Foundation

struct EnergyParameter: MetricParameter {
    /// Range: 0..1. Less is better.
    /// Percentage of max battery capacity consumption in a period of time (60s).
    let batteryСonsumption: Float
    /// Calculated based on device current battery level.
    /// Range: -1, 0..1. More is better. -1 if not applicable for this device.
    let batteryCapacity: Float

    // MARK: MetricParameter protocol

    let type: MetricParameterType = .energy

    /// Calculated based on device current battery level.
    var value: Float {
        return 1 - (self.batteryСonsumption * self.batteryCapacity)
    }
}
