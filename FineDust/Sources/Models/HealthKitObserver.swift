//
//  HealthKitObserver.swift
//  FineDust
//
//  Created by Presto on 25/07/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import RxRelay
import RxSwift

final class HealthKitObserver {
  
  static let shared = HealthKitObserver()
  
  private init() { }
  
  private let didAuthorizedRelay = BehaviorRelay<Bool>(value: false)
}

extension HealthKitObserver {
  
  func didAuthorized() {
    didAuthorizedRelay.accept(true)
  }
  
  var authorized: Observable<Bool> {
    return didAuthorizedRelay.asObservable()
  }
}
