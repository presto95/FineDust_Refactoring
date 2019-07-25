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

final class HealthKitService: HealthKitServiceType {
  
  private let disposeBag = DisposeBag()
  
  private let healthStore = HKHealthStore()
  
  var isAuthorized: Bool {
    guard let stepCountQuantityType = HKObjectType.quantityType(forIdentifier: .stepCount),
      let distanceQuantityType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)
      else { return false }
    return healthStore.authorizationStatus(for: stepCountQuantityType) == .sharingAuthorized
      && healthStore.authorizationStatus(for: distanceQuantityType) == .sharingAuthorized
  }
  
  func requestAuthorization() -> Observable<Bool> {
    guard let stepCountQuantityType = HKObjectType.quantityType(forIdentifier: .stepCount),
      let distanceQuantityType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)
      else { return .empty() }
    return .create { observer in
      let types = Set([stepCountQuantityType, distanceQuantityType])
      self.healthStore
        .requestAuthorization(toShare: types, read: types) { success, error in
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
  
  func todaySteps() -> Observable<Double> {
    return .create { observer in
      self.requestHealthKitData(healthKitQuery: .steps, startDate: .start(), endDate: .init(), hourInterval: 24)
        .subscribe(
          onNext: { value, _ in
            observer.onNext(value)
            observer.onCompleted()
        },
          onError: { error in
            observer.onError(error)
        })
        .disposed(by: self.disposeBag)
      return Disposables.create()
    }
  }
  
  func todayDistance() -> Observable<Double> {
    return .create { observer in
      self.requestHealthKitData(healthKitQuery: .distance, startDate: .start(), endDate: .init(), hourInterval: 24)
        .subscribe(
          onNext: { value, _ in
            observer.onNext(value)
            observer.onCompleted()
        },
          onError: { error in
            observer.onError(error)
        })
        .disposed(by: self.disposeBag)
      return Disposables.create()
    }
  }
  
  func todayDistancePerHour() -> Observable<HourIntakePair> {
    return .create { observer in
      var hourIntakePair = HourIntakePair()
      let semaphore = DispatchSemaphore(value: 0)
      var temp = 0
      self.requestHealthKitData(healthKitQuery: .distance, startDate: .start(), endDate: .end(), hourInterval: 1)
        .subscribe(
          onNext: { value, hour in
            let value = value < 500 ? 0 : Int(value)
            hourIntakePair[Hour(rawValue: hour) ?? .default] = value
            temp += 1
            if temp == 24 {
              semaphore.signal()
            }
        },
          onError: { error in
            for hour in Hour.allCases {
              hourIntakePair[hour] = 0
            }
            semaphore.signal()
        })
        .disposed(by: self.disposeBag)
      semaphore.wait()
      observer.onNext(hourIntakePair)
      observer.onCompleted()
      return Disposables.create()
    }
  }
  
  func todayDistancePerHour(from startDate: Date, to endDate: Date) -> Observable<DateHourIntakePair> {
    return .create { observer in
      var hourIntakePair = HourIntakePair()
      var dateHourIntakePair = DateHourIntakePair()
      let interval = Calendar.current.dateComponents([.day], from: startDate, to: endDate)
      guard let day = interval.day, day >= 0 else {
        observer.onError(NSError(domain: "", code: 0, userInfo: nil))
        return Disposables.create()
      }
      let semaphore = DispatchSemaphore(value: 0)
      var temp = 0
      for index in 0..<day {
        let indexDate = startDate.after(days: index)
        self.requestHealthKitData(healthKitQuery: .distance, startDate: indexDate.start, endDate: indexDate.end, hourInterval: 1)
          .subscribe(
            onNext: { value, hour in
              let value = value < 500 ? 0 : Int(value)
              hourIntakePair[Hour(rawValue: hour) ?? .default] = value
              dateHourIntakePair[indexDate.start] = hourIntakePair
              temp += 1
              if temp == (day + 1) * 24 {
                semaphore.signal()
              }
          }, onError: { error in
            for hour in Hour.allCases {
              hourIntakePair[hour] = 0
              temp += 1
            }
            dateHourIntakePair[indexDate.start] = hourIntakePair
            if temp == (day + 1) * 24 {
              semaphore.signal()
            }
          })
          .disposed(by: self.disposeBag)
      }
      semaphore.wait()
      observer.onNext(dateHourIntakePair)
      observer.onCompleted()
      return Disposables.create()
    }
  }
}

// MARK: - Private Method

private extension HealthKitService {
  
  func requestHealthKitData(healthKitQuery: HealthKitQuery,
                            startDate: Date,
                            endDate: Date,
                            hourInterval: Int) -> Observable<(value: Double, hour: Int)> {
    return .create { observer in
      guard let quantityType = HKQuantityType.quantityType(forIdentifier: healthKitQuery.identifier) else {
        observer.onError(HealthKitError.unexpectedIdentifier)
      }
      let interval = DateComponents(hour: hourInterval)
      let predicate = HKQuery.predicateForSamples(withStart: startDate,
                                                  end: endDate,
                                                  options: .strictStartDate)
      let query = HKStatisticsCollectionQuery(quantityType: quantityType,
                                              quantitySamplePredicate: predicate,
                                              options: [.cumulativeSum],
                                              anchorDate: startDate,
                                              intervalComponents: interval)
      query.initialResultsHandler = { query, results, error in
        if let _ = error {
          observer.onError(HealthKitError.queryNotValid)
        }
        if let results = results {
          if results.statistics().isEmpty {
            observer.onError(HealthKitError.queryNotSearched)
          } else {
            results.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
              let hour = Int(DateFormatter.hour.string(from: statistics.startDate)) ?? 0
              if let quantity = statistics.sumQuantity() {
                let quantityValue = quantity.doubleValue(for: healthKitQuery.unit)
                observer.onNext((quantityValue, hour))
                observer.onCompleted()
              } else {
                observer.onNext((0, hour))
                observer.onCompleted()
              }
            }
          }
        } else {
          observer.onError(HealthKitError.queryExecutedFailed)
        }
      }
      return Disposables.create()
    }
  }
}
