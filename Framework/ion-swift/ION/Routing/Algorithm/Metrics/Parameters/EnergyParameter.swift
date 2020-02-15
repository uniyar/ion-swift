//
//  EnergyParameter.swift
//  ion-swift
//
//  Created by Ivan Manov on 16.02.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import Foundation

struct EnergyParameter: MetricParameter {
    /// Percentage of max battery capacity consumption in a period of time (1s).
    let batteryСonsumption: Float
    /// Calculated based on device current battery level.
    let batteryCapacity: Float

    // MARK: MetricParameter protocol

    let type: MetricParameterType = .energy

    var value: Float {
        return 1 - (self.batteryСonsumption * self.batteryCapacity)
    }
}
