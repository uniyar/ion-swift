//
//  Device.swift
//  ion-swift
//
//  Created by Ivan Manov on 15.02.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import UIKit

public class Device {
    public static let shared = Device()

    private let systemDevice = UIDevice.current

    // MARK: Overrided functions

    public init() {
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

    // MARK: Public variables

    public var batteryStateChanged: ((_ batteryState: DeviceBatteryState) -> Void)?
    public var batteryLevelChanged: ((_ batteryLevel: Float) -> Void)?

    /// Device name. e.g. "My iPhone"
    public var name: String {
        return self.systemDevice.name
    }

    /// a UUID that may be used to uniquely identify the device, same across apps from a single vendor.
    public var identifier: String {
        return self.systemDevice.identifierForVendor!.uuidString
    }

    /// System version. e.g. @"12.1"
    public var systemVersion: String {
        return self.systemDevice.systemVersion
    }
}

// MARK: Battery info

extension Device {
    public enum DeviceBatteryState: Int {
        // if monitoring disabled
        case unknown
        case unplugged
        case charging
        case full
        // if tvOS / car play case. Take as infinity power source
        case notApplicable
    }

    // MARK: Public variables

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

    @objc private func batteryStateDidChange(_: Notification) {
        self.batteryStateChanged?(self.batteryState)
    }

    @objc private func batteryLevelDidChange(_: Notification) {
        self.batteryLevelChanged?(self.batteryLevel)
    }
}
