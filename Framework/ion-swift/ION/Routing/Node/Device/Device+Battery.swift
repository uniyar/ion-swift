//
//  Device.swift
//  ion-swift
//
//  Created by Ivan Manov on 15.02.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import UIKit

/// Current device battery state
public enum DeviceBatteryState: Int, Codable {
    /// if monitoring disabled
    case unknown = -1
    /// If device is unplugged from the power source
    case unplugged = 0
    /// If device is charging
    case charging = 1
    /// If device is fully charged. Could be in charging state also, but w/o charging
    case full = 2
    /// If tvOS / car play case. Take as infinity power source
    case notApplicable = 3
}

/// Battery info
extension Device {
    internal func subscribeBatteryChanges() {
        self.systemDevice.isBatteryMonitoringEnabled = true

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(batteryStateDidChange),
            name: UIDevice.batteryStateDidChangeNotification,
            object: self.systemDevice
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(batteryLevelDidChange),
            name: UIDevice.batteryLevelDidChangeNotification,
            object: self.systemDevice
        )
    }

    internal func unsubscribeBatteryChanges() {
        self.systemDevice.isBatteryMonitoringEnabled = false

        NotificationCenter.default.removeObserver(
            self,
            name: UIDevice.batteryStateDidChangeNotification,
            object: self.systemDevice
        )

        NotificationCenter.default.removeObserver(
            self,
            name: UIDevice.batteryLevelDidChangeNotification,
            object: self.systemDevice
        )
    }

    /// Battery info availability
    public var batteryInfoAvailability: Bool {
        return self.systemDevice.isBatteryMonitoringEnabled
    }

    /// Current battery state
    public var batteryState: DeviceBatteryState {
        if self.systemDevice.userInterfaceIdiom == .tv ||
            self.systemDevice.userInterfaceIdiom == .carPlay {
            return .notApplicable
        }

        switch self.systemDevice.batteryState {
        case .unknown:
            return .unknown
        case .unplugged:
            return .unplugged
        case .charging:
            return .charging
        case .full:
            return .full
        default:
            return .unknown
        }
    }

    /// Current battery level. From 0 .. to 1.0. -1.0 if DeviceBatteryState .unknown
    public var batteryLevel: Float {
        return self.systemDevice.batteryLevel
    }

    // MARK: Notifications

    @objc internal func batteryStateDidChange(_: Notification) {
        self.batteryStateChanged?(self.batteryState)
    }

    @objc internal func batteryLevelDidChange(_: Notification) {
        self.batteryLevelChanged?(self.batteryLevel)
    }
}
