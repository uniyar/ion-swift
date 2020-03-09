//
//  IONProtocolManager.swift
//  ion-swift
//
//  Created by Ivan Manov on 08.03.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import Foundation

internal class IONProtocolManager {
    internal static let shared = IONProtocolManager()

    let metricsInfo = [IONMetricParameter]()

    private var pullTimer: Timer?

    init() {
        EnergyMetricProvider.shared.start()

        self.preparePullTimer()
    }

    // MARK: Public methods

    func cost(for _: String) -> Int {
        return 100 - Int.random(in: 0 ... 100)
    }

    func proceed(metrics _: IONMetricsMessage) {
//        print(message)
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

    private func pull(metrics _: IONMetricsMessage) {
//        print(message)
    }
}

extension IONProtocolManager {
    fileprivate func energy() -> IONMetricParameter? {
        guard let energyMetric = EnergyMetricProvider.shared.value else {
            return nil
        }

        let energy = IONMetricParameter(
            createdDate: Date(),
            sourceId: nil,
            destinationId: IONLocalPeer.shared?.identifier.UUIDString,
            type: .energy,
            value: energyMetric.value
        )

        return energy
    }

    fileprivate func computation() -> IONMetricParameter? {
        let computation = IONMetricParameter(
            createdDate: Date(),
            sourceId: nil,
            destinationId: IONLocalPeer.shared?.identifier.UUIDString,
            type: .computation,
            value: Float.random(in: 0 ... 1) // TODO: Last known value
        )

        return computation
    }
}
