//
//  EnergyMetricProvider.swift
//  ion-swift
//
//  Created by Ivan Manov on 08.03.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import Foundation

class EnergyMetricProvider {
    static let shared = EnergyMetricProvider()

    private var consumptionTimer: Timer?

    private var lastMinuteCapacity: Float?
    private var batteryСonsumption: Float?
    private var batteryCapacity: Float {
        let level = Device.shared.batteryLevel
        return level < 0 ? 1 : level
    }

    var value: EnergyParameter? {
        if let batteryСonsumption = self.batteryСonsumption {
            return EnergyParameter(
                batteryСonsumption: batteryСonsumption,
                batteryCapacity: self.batteryCapacity
            )
        }

        return nil
    }

    // MARK: Public methods

    func start() {
        Device.shared.batteryStateChanged = { batteryState in
            switch batteryState {
            case .charging, .full, .notApplicable:
                self.batteryСonsumption = 0.0
            default: break
            }
        }

        self.consumptionTimer = Timer.repeatAction(interval: 60, action: { _, _ in
            if Device.shared.batteryState == .unplugged,
                let lastMinuteCapacity = self.lastMinuteCapacity {
                let diff = self.batteryCapacity - lastMinuteCapacity
                if diff > 0 {
                    self.batteryСonsumption = 0
                } else {
                    self.batteryСonsumption = abs(diff)
                }
            }

            self.lastMinuteCapacity = self.batteryCapacity
        })
        self.consumptionTimer?.fire()
    }

    func stop() {
        self.consumptionTimer = nil
    }
}
