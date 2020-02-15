//
//  MetricsTests.swift
//  ion-swiftTests
//
//  Created by Ivan Manov on 15.02.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import XCTest

class MetricsTests: XCTestCase {
    func testCoefficientsBalance() {
        let coefficients: [MetricCoefficient] = [
            MetricCoefficient(type: .loss, value: 0.25),
            MetricCoefficient(type: .bandwidth, value: 0.25),
            MetricCoefficient(type: .computation, value: 0.25),
            MetricCoefficient(type: .time, value: 0.25)
        ]
        
        XCTAssertTrue(Metric.check(coefficients))
        
        let coefficients2: [MetricCoefficient] = [
            MetricCoefficient(type: .loss, value: 0.26),
            MetricCoefficient(type: .bandwidth, value: 0.25),
            MetricCoefficient(type: .computation, value: 0.25),
            MetricCoefficient(type: .time, value: 0.25)
        ]
        
        XCTAssertFalse(Metric.check(coefficients2))
    }
    
    private struct TestParameter: MetricParameter {
        var type: MetricParameterType
        var value: Float
    }
    
    func testValidateParameters() {
        let parameters: [MetricParameter] = [
            TestParameter(type: .loss, value: 1.00001),
            TestParameter(type: .bandwidth, value: 1),
            TestParameter(type: .computation, value: 1),
            TestParameter(type: .time, value: 1)
        ]
        
        XCTAssertFalse(Metric.check(parameters))
    }
    
    func testMetricCalculation() {
        // Normal balance case
        let parameters: [MetricParameter] = [
            TestParameter(type: .loss, value: 1),
            TestParameter(type: .bandwidth, value: 1),
            TestParameter(type: .computation, value: 1),
            TestParameter(type: .time, value: 1)
        ]
        
        let coefficients: [MetricCoefficient] = [
            MetricCoefficient(type: .loss, value: 0.25),
            MetricCoefficient(type: .bandwidth, value: 0.25),
            MetricCoefficient(type: .computation, value: 0.25),
            MetricCoefficient(type: .time, value: 0.25)
        ]
        
        let metricValue = Metric.calculate(with: coefficients, for: parameters)
        
        XCTAssertEqual(metricValue, 1, accuracy: .leastNormalMagnitude)
        
        // Value 10 loss parameter case
        let parameters2: [MetricParameter] = [
            TestParameter(type: .loss, value: 10),
            TestParameter(type: .bandwidth, value: 1),
            TestParameter(type: .computation, value: 1),
            TestParameter(type: .time, value: 1)
        ]
        
        let metricValue2 = Metric.calculate(with: coefficients, for: parameters2)
        
        XCTAssertEqual(metricValue2, 0, accuracy: .leastNormalMagnitude)
        
        // 0.9 loss parameter case
        let parameters3: [MetricParameter] = [
            TestParameter(type: .loss, value: 0.9),
            TestParameter(type: .bandwidth, value: 1),
            TestParameter(type: .computation, value: 1),
            TestParameter(type: .time, value: 1)
        ]
        
        let metricValue3 = Metric.calculate(with: coefficients, for: parameters3)
        
        XCTAssertEqual(metricValue3, 0.975000023, accuracy: .leastNormalMagnitude)
        
        // Dublicated parameters case
        let parameters4: [MetricParameter] = [
            TestParameter(type: .loss, value: 1),
            TestParameter(type: .loss, value: 1),
            TestParameter(type: .computation, value: 1),
            TestParameter(type: .time, value: 1)
        ]
        
        let metricValue4 = Metric.calculate(with: coefficients, for: parameters4)
        
        XCTAssertEqual(metricValue4, 0, accuracy: .leastNormalMagnitude)
        
        // Unsorted parameters case
        let parameters5: [MetricParameter] = [
            TestParameter(type: .bandwidth, value: 1),
            TestParameter(type: .loss, value: 1),
            TestParameter(type: .computation, value: 1),
            TestParameter(type: .time, value: 1)
        ]
        
        let metricValue5 = Metric.calculate(with: coefficients, for: parameters5)
        
        XCTAssertEqual(metricValue5, 1, accuracy: .leastNormalMagnitude)
    }
}
