//
//  IONProtocolManager.swift
//  ion-swift
//
//  Created by Ivan Manov on 08.03.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import Foundation

class IONProtocolManager {
    static let shared = IONProtocolManager()

    let metricsInfo = [IONMetricParameter]()

    private var pullTimer: Timer?

    init() {
        self.preparePullTimer()
    }

    // MARK: Public methods

    func proceed(metrics message: IONMetricsMessage) {
        print(message)
        // TODO: Update metricsInfo based on date
    }

    // MARK: Private methods

    private func preparePullTimer() {
        self.pullTimer = Timer.repeatAction(interval: 5) { _, _ in
            let message = self.collectMetricsMessage()
            self.pull(metrics: message)
        }
        self.pullTimer?.fire()
    }

    private func collectMetricsMessage() -> IONMetricsMessage {
        var parameters = [IONMetricParameter]()

        if let energy = self.energy() {
            parameters.append(energy)
        }

        if let computation = self.computation() {
            parameters.append(computation)
        }

        return IONMetricsMessage(parameters: parameters)
    }

    private func pull(metrics message: IONMetricsMessage) {
        print(message)
    }
}

extension IONProtocolManager {
    fileprivate func energy() -> IONMetricParameter? {
        let energy = IONMetricParameter(
            createdDate: Date(),
            sourceId: nil,
            destinationId: IONLocalPeer.shared.identifier.UUIDString,
            type: .energy,
            value: Float.random(in: 0 ... 1) // TODO: Last known value
        )

        return energy
    }

    fileprivate func computation() -> IONMetricParameter? {
        let computation = IONMetricParameter(
            createdDate: Date(),
            sourceId: nil,
            destinationId: IONLocalPeer.shared.identifier.UUIDString,
            type: .computation,
            value: Float.random(in: 0 ... 1) // TODO: Last known value
        )

        return computation
    }
}
