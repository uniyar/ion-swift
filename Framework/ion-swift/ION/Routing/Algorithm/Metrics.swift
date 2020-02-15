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

    /// Check coefficients vector is balanced
    static func check(_ coefficients: [MetricCoefficient]) -> Bool {
        let sum: Float = coefficients.map { $0.value }.reduce(0, +)

        return sum >= 0 && sum <= 1
    }

    /// Check parameters vector is valid
    static func check(_ parameters: [MetricParameter]) -> Bool {
        return parameters.allSatisfy { $0.value <= 1 && $0.value >= 0 }
    }

    /// Check coefficients and parameters vectors are full and return their pairs
    private static func retreivePairs(
        of coefficients: [MetricCoefficient],
        to parameters: [MetricParameter]
    ) -> [(MetricCoefficient, MetricParameter)]? {
        if !Metric.check(coefficients) || !Metric.check(parameters) { return nil }

        let coefficientsNum = coefficients.count
        let parametersNum = parameters.count

        if coefficientsNum != parametersNum { return nil }

        let pairs = zip(coefficients, parameters).map { (arg0) -> (MetricCoefficient, MetricParameter)? in
            let (coefficient, parameter) = arg0

            if coefficient.type == parameter.type {
                return arg0
            } else if let parameter = parameters.first(where: { $0.type == coefficient.type }) {
                return (coefficient, parameter)
            }

            return nil
        }

        if pairs.count == coefficientsNum,
            pairs.count == parametersNum {
            return pairs as? [(MetricCoefficient, MetricParameter)]
        }

        return nil
    }
}
