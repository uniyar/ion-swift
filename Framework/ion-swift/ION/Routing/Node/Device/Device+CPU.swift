//
//  Device+CPU.swift
//  ion-swift
//
//  Created by Ivan Manov on 15.02.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import Foundation

extension Device {
    internal func subscribeCPUChanges() {
        self.cpuUpdateTimer =
            Timer.repeatAction(interval: 5, action: { _, _ in
                self.cpuLoadChanged?(self.cpuLoad())
            })
        self.cpuUpdateTimer?.fire()
    }

    internal func unsubscribeCPUChanges() {
        self.cpuUpdateTimer?.stop()
        self.cpuUpdateTimer = nil
    }

    /// Current CPU load info
    private func cpuLoad() -> Float {
        var cpuUsageInfo = ""
        var cpuInfo: processor_info_array_t!
        var prevCpuInfo: processor_info_array_t?
        var numCpuInfo: mach_msg_type_number_t = 0
        var numPrevCpuInfo: mach_msg_type_number_t = 0
        var numCPUs: uint = 0
        let CPUUsageLock: NSLock = NSLock()
        var usage: Float32 = 0

        let mibKeys: [Int32] = [CTL_HW, HW_NCPU]
        mibKeys.withUnsafeBufferPointer { mib in
            var sizeOfNumCPUs: size_t = MemoryLayout<uint>.size
            let status = sysctl(processor_info_array_t(mutating: mib.baseAddress), 2, &numCPUs, &sizeOfNumCPUs, nil, 0)
            if status != 0 {
                numCPUs = 1
            }
        }

        var numCPUsU: natural_t = 0
        let err: kern_return_t = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUsU, &cpuInfo, &numCpuInfo)
        if err == KERN_SUCCESS {
            CPUUsageLock.lock()

            for i in 0 ..< Int32(numCPUs) {
                var inUse: Int32
                var total: Int32
                if let prevCpuInfo = prevCpuInfo {
                    inUse = cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_USER)]
                        - prevCpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_USER)]
                        + cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_SYSTEM)]
                        - prevCpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_SYSTEM)]
                        + cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_NICE)]
                        - prevCpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_NICE)]
                    total = inUse + (cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_IDLE)]
                        - prevCpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_IDLE)])
                } else {
                    inUse = cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_USER)]
                        + cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_SYSTEM)]
                        + cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_NICE)]
                    total = inUse + cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_IDLE)]
                }
                let coreInfo = Float(inUse) / Float(total)
                usage += coreInfo
//                print(String(format: "Core: %u Usage: %f", i, Float(inUse) / Float(total)))
            }
            cpuUsageInfo = String(format: "%.2f", 100 * Float(usage) / Float(numCPUs))
            CPUUsageLock.unlock()

            if let prevCpuInfo = prevCpuInfo {
                let prevCpuInfoSize: size_t = MemoryLayout<integer_t>.stride * Int(numPrevCpuInfo)
                vm_deallocate(mach_task_self_, vm_address_t(bitPattern: prevCpuInfo), vm_size_t(prevCpuInfoSize))
            }

            prevCpuInfo = cpuInfo
            numPrevCpuInfo = numCpuInfo

            cpuInfo = nil
            numCpuInfo = 0
        } else {
            print("Error!")
        }

        print(cpuUsageInfo)

        return usage
    }
}
