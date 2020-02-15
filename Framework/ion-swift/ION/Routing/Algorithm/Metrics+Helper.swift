//
//  Metrics+Helper.swift
//  ion-swift
//
//  Created by Ivan Manov on 15.02.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import Foundation

extension Metric {
    /// Returns auto balanced coefficients vector based on parameters priority vector
    /// - Parameter priorities: Parameters priority vector
    static func coefficients(from priorities: [MetricParameterPriority]) -> [MetricCoefficient]? {
        if !Metric.check(priorities) { return nil }

        let basis = Metric.basis(from: priorities)

        let coeffs = priorities.map { (priority) -> MetricCoefficient in
            let temp = Float(priority.value)
            let result = temp / 100 / Float(priorities.count) / basis

            return MetricCoefficient(type: priority.type, value: result)
        }

        return Metric.check(coeffs) ? coeffs : nil
    }

    /// Check coefficients vector is balanced
    static func check(_ coefficients: [MetricCoefficient]) -> Bool {
        let sum: Float = coefficients.map { $0.value }.reduce(0, +)

        return 0 ... 1 ~= sum
    }

    /// Check parameters vector is valid
    static func check(_ parameters: [MetricParameter]) -> Bool {
        return parameters.allSatisfy { 0 ... 1 ~= $0.value }
    }

    /// Check priorities vector is valid
    static func check(_ priorities: [MetricParameterPriority]) -> Bool {
        return priorities.allSatisfy { 0 ... 100 ~= $0.value }
    }

    /// Check coefficients and parameters vectors are full and return their pairs
    static func retreivePairs(
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

    private static func basis(from priorities: [MetricParameterPriority]) -> Float {
        let floats = priorities.map { Float($0.value) / 100 } // Array of floats
        let sum = floats.reduce(0, +) // Sum of array floats
        let result = sum / Float(priorities.count)

        return result
    }
}
