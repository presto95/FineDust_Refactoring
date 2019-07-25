//
//  HealthKitObserver.swift
//  FineDust
//
//  Created by Presto on 25/07/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import RxRelay

final class HealthKitObserver {
  
  static let shared = HealthKitObserver()
  
  private init() { }
  
  let authorized = PublishRelay<Void>()
}
