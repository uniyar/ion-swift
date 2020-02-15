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

    internal let systemDevice = UIDevice.current

    // MARK: Overrided functions

    public init() {
        self.subscribeBatteryChanges()
        self.subscribeCPUChanges()
    }

    // MARK: Public variables

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

    // MARK: Public variables / Battery

    public var batteryStateChanged: ((_ batteryState: DeviceBatteryState) -> Void)?
    public var batteryLevelChanged: ((_ batteryLevel: Float) -> Void)?

    // MARK: Public variables / CPU

    internal var cpuUpdateTimer: Timer?
    public var cpuLoadChanged: ((_ cpuLoad: Float) -> Void)?
}
