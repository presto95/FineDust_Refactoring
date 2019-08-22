//
//  HealthKitQuery.swift
//  FineDust
//
//  Created by Presto on 25/07/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import HealthKit

enum HealthKitQuery {
  
  case stepCount
  
  case distance
}

extension HealthKitQuery {
  
  var identifier: HKQuantityTypeIdentifier {
    switch self {
    case .stepCount:
      return .stepCount
    case .distance:
      return .distanceWalkingRunning
    }
  }
  
  var unit: HKUnit {
    switch self {
    case .stepCount:
      return .count()
    case .distance:
      return .meter()
    }
  }
}
