//
//  Node+Metrics.swift
//  ion-swift
//
//  Created by Ivan Manov on 15.02.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import Foundation

/// Node related parameters
struct NodeParameters: Codable {
    // MARK: Computation info

    /// Range: 0..1. Less is better.
    /// Current CPU usage
    var cpuUsage: Float?

    // MARK: Battery info

    /// Range: -1, 0..1. More is better. -1 if not applicable for this device.
    /// Calculated based on device current battery level.
    var batteryCapacity: Float?
    /// Check DeviceBatteryState for more info
    var batteryState: DeviceBatteryState?
    /// Range: 0..1. Less is better.
    /// Percentage of max battery capacity consumption in a period of time (1s).
    var batteryСonsumption: Float?
}
