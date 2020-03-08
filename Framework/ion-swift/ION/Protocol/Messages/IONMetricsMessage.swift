//
//  IONMetricsMessage.swift
//  ion-swift
//
//  Created by Ivan Manov on 08.03.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import Foundation

struct IONMetricParameter: Codable, MetricParameter {
    /// Created at date string
    var createdDate: Date?
    /// Source node id. In case of connection info
    var sourceId: String?
    /// Destination node id. In case of connection info
    /// Owner of data node id. In case of device info
    var destinationId: String?

    // MARK: MetricParameter protocol implementation

    /// Parameter type
    var type: MetricParameterType
    /// Parameter value.
    /// Always in range: 0..1. More is better.
    var value: Float
}

struct IONMetricsMessage: Codable {
    /// Metric parameters array
    var parameters: [IONMetricParameter]?
}
