//
//  HealthKitProvider.swift
//  FineDust
//
//  Created by Presto on 25/07/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import Foundation
import HealthKit

import RxSwift

protocol HealthKitProviderType: class { }

final class HealthKitProvider: HealthKitProviderType {
  
  private let healthStore = HKHealthStore()
  
  
  
  func requestAuthorization() -> Observable<Bool> {
    guard let stepCountQuantityType = HKObjectType.quantityType(forIdentifier: .stepCount),
      let distanceQuantityType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)
      else { return .empty() }
    let stepCountAuthorizationStatus = healthStore.authorizationStatus(for: stepCountQuantityType)
    let distanceAuthorizationStatus = healthStore.authorizationStatus(for: distanceQuantityType)
    return .create { observer in
      self.healthStore
        .requestAuthorization(toShare: [stepCountQuantityType, distanceQuantityType],
                              read: [stepCountQuantityType, distanceQuantityType]) { success, error in
                                if let error = error {
                                  observer.onError(error)
                                  return
                                }
                                observer.onNext(success)
                                observer.onCompleted()
                                
      }
      return Disposables.create()
    }
    
  }
  
  func fetchTodaySteps() {
    
  }
  
  func fetchTodayDistance() {
    
  }
  
  func fetchTodayDistancePerHour() {
    
  }
  
  func fetchTodayDistancePerHour(from startDate: Date, to endDate: Date) {
    
  }
}

// MARK: - Private Method

private extension HealthKitProvider {
  
  
}
