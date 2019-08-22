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
  
  @discardableResult
  func requestAuthorization() -> Single<Result<Bool, Error>> {
    guard let stepCountQuantityType = HKObjectType.quantityType(forIdentifier: .stepCount),
      let distanceQuantityType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)
      else { return .just(.failure(HealthKitError.invalidQuery)) }
    return .create { observer in
      let types = Set([stepCountQuantityType, distanceQuantityType])
      self.healthStore.requestAuthorization(toShare: types, read: types) { success, error in
        if let error = error {
          observer(.success(.failure(error)))
        }
        observer(.success(.success(success)))
      }
      return Disposables.create()
    }
    
  }
  
  func todayStepCount() -> Single<Result<Double, Error>> {
    return requestHealthKitData(healthKitQuery: .stepCount,
                                startDate: .start(),
                                endDate: .init(),
                                hourInterval: .day)
      .map { $0.map { $0.value } }
  }
  
  func todayDistance() -> Single<Result<Double, Error>> {
    return requestHealthKitData(healthKitQuery: .distance,
                                startDate: .start(),
                                endDate: .init(),
                                hourInterval: .day)
      .map { $0.map { $0.value } }
  }
  
  func todayDistancePerHour() -> Single<Result<[Hour: Int], Error>> {
    return .create { observer in
      var hourIntakePair = [Hour: Int]()
      let semaphore = DispatchSemaphore(value: 0)
      var temp = 0
      self.requestHealthKitData(healthKitQuery: .distance,
                                startDate: .start(),
                                endDate: .end(),
                                hourInterval: .onetime)
        .subscribe(onSuccess: { result in
          if result.failure != nil {
            for hour in Hour.allCases {
              hourIntakePair[hour] = 0
            }
            semaphore.signal()
            return
          }
          guard let success = result.success else { return }
          let value = success.value < 500 ? 0 : Int(success.value)
          let hour = Hour(rawValue: success.hour) ?? .default
          hourIntakePair[hour] = value
          temp += 1
          if temp == 24 {
            semaphore.signal()
          }
        })
        .disposed(by: self.disposeBag)
      semaphore.wait()
      observer(.success(.success(hourIntakePair)))
      return Disposables.create()
    }
  }
  
  func todayDistancePerHour(from startDate: Date,
                            to endDate: Date) -> Single<Result<[Date: [Hour: Int]], Error>> {
    return .create { observer in
      var hourIntakePair = [Hour: Int]()
      var dateHourIntakePair = [Date: [Hour: Int]]()
      let interval = Calendar.current.dateComponents([.day], from: startDate, to: endDate)
      guard let day = interval.day, day >= 0 else {
        observer(.success(.failure(HealthKitError.default)))
        return Disposables.create()
      }
      let semaphore = DispatchSemaphore(value: 0)
      var temp = 0
      for index in 0..<day {
        let indexDate = startDate.after(days: index)
        self.requestHealthKitData(healthKitQuery: .distance,
                                  startDate: indexDate.start,
                                  endDate: indexDate.end,
                                  hourInterval: .onetime)
          .subscribe(onSuccess: { result in
            if result.failure != nil {
              for hour in Hour.allCases {
                hourIntakePair[hour] = 0
                temp += 1
              }
              dateHourIntakePair[indexDate.start] = hourIntakePair
              if temp == (day + 1) * 24 {
                semaphore.signal()
              }
              return
            }
            guard let success = result.success else { return }
            let value = success.value < 500 ? 0 : Int(success.value)
            let hour = Hour(rawValue: success.hour) ?? .default
            hourIntakePair[hour] = value
            dateHourIntakePair[indexDate.start] = hourIntakePair
            temp += 1
            if temp == (day + 1) * 24 {
              semaphore.signal()
            }
          })
          .disposed(by: self.disposeBag)
      }
      semaphore.wait()
      observer(.success(.success(dateHourIntakePair)))
      return Disposables.create()
    }
  }
}

// MARK: - Private Method

private extension HealthKitService {
  
  func requestHealthKitData(
    healthKitQuery: HealthKitQuery,
    startDate: Date,
    endDate: Date,
    hourInterval: HealthKitHourInterval
    ) -> Single<Result<(value: Double, hour: Int), Error>> {
    return .create { observer in
      guard let quantityType
        = HKQuantityType.quantityType(forIdentifier: healthKitQuery.identifier) else {
          observer(.success(.failure(HealthKitError.unexpectedIdentifier)))
          return Disposables.create()
      }
      let interval = DateComponents(hour: hourInterval.rawValue)
      let predicate = HKQuery.predicateForSamples(withStart: startDate,
                                                  end: endDate,
                                                  options: .strictStartDate)
      let query = HKStatisticsCollectionQuery(quantityType: quantityType,
                                              quantitySamplePredicate: predicate,
                                              options: [.cumulativeSum],
                                              anchorDate: startDate,
                                              intervalComponents: interval)
      query.initialResultsHandler = { query, results, error in
        if error != nil {
          observer(.success(.failure(HealthKitError.invalidQuery)))
        }
        if let results = results {
          if results.statistics().isEmpty {
            observer(.success(.failure(HealthKitError.queryNotSearched)))
          } else {
            results.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
              let hour = Int(DateFormatter.hour.string(from: statistics.startDate)) ?? 0
              if let quantity = statistics.sumQuantity() {
                let quantityValue = quantity.doubleValue(for: healthKitQuery.unit)
                observer(.success(.success((quantityValue, hour))))
              } else {
                observer(.success(.success((0, hour))))
              }
            }
          }
        } else {
          observer(.success(.failure(HealthKitError.queryExecutedFailed)))
        }
      }
      return Disposables.create()
    }
  }
}
