//
//  IONMetricsMessage.swift
//  ion-swift
//
//  Created by Ivan Manov on 08.03.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import Foundation

struct IONMetricParameter: Codable, MetricParameter {
    var sourceId: String?
    var destinationId: String?

    var type: MetricParameterType
    var value: Float
}

struct IONMetricsMessage: Codable {
    var parameters: [IONMetricParameter]?
}
