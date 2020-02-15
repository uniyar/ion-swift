//
//  Metrics.swift
//  ion-swift
//
//  Created by Ivan Manov on 15.02.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import Foundation

enum MetricParameterType: CaseIterable {
    case loss
    case time
    case bandwidth
    case computation
    case energy
}

struct MetricCoefficient {
    let type: MetricParameterType
    let value: Float
}

/// Subjective priority in percent based on parameter contribution into metric
struct MetricParameterPriority {
    let type: MetricParameterType
    /// Range: 0..100. In percents. If higher then parameter contribution would be also higher.
    let value: Int
}

protocol MetricParameter {
    var type: MetricParameterType { get }
    var value: Float { get }
}

class Metric {
    /// Calculate metric
    /// - Parameters:
    ///   - coefficients: coefficients vector
    ///   - parameters: parameters vector
    static func calculate(with coefficients: [MetricCoefficient],
                          for parameters: [MetricParameter]) -> Float {
        if let pairs = Metric.retreivePairs(of: coefficients, to: parameters) {
            let metricResult: Float = pairs.map { $0.0.value * $0.1.value }.reduce(0, +)

            return metricResult
        }

        return 0
    }
}
