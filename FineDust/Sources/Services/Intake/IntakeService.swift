//
//  IntakesGenerator.swift
//  FineDust
//
//  Created by Presto on 28/01/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import Foundation

import RxSwift

final class IntakeService: IntakeServiceType {
  
  private let disposeBag = DisposeBag()
  
  private let healthKitService: HealthKitServiceType
  
  private let dustAPIService: DustAPIServiceType
  
  private let persistenceService: PersistenceServiceType
  
  init(healthKitService: HealthKitServiceType = HealthKitService(),
       dustAPIService: DustAPIServiceType = DustAPIService(),
       persistenceService: PersistenceServiceType = PersistenceService()) {
    self.healthKitService = healthKitService
    self.dustAPIService = dustAPIService
    self.persistenceService = persistenceService
  }
  
  func todayIntake() -> Single<Result<DustPair<Int>, Error>> {
    if !self.healthKitService.isAuthorized {
      return .just(.failure(HealthKitError.notAuthorized))
    }
    return Single
      .zip(dustAPIService.dayInfo(),
           healthKitService.todayDistancePerHour()) { dayInfo, todayDistancePerHour -> Result<DustPair<Int>, Error> in
            guard let dayInfo = dayInfo.success,
              let todayDistancePerHour = todayDistancePerHour.success
              else { return .failure(NSError(domain: "", code: 0, userInfo: nil)) }
            return .success(self.totalHourlyIntake(dayInfo, todayDistancePerHour))
    }
  }
  
  func weekIntake() -> Single<Result<[DustPair<Int>], Error>> {
    if !self.healthKitService.isAuthorized {
      return .error(HealthKitError.notAuthorized)
    }
    return .create { observer in
      let startDate = Date.before(days: 6)
      let endDate = Date.before(days: 1)
      let savedIntakePerDate = self.persistenceService.intakes(from: startDate, to: endDate)
      var fineDustIntakePerDate: [Date: Int] = [:]
      var ultraFineDustIntakePerDate: [Date: Int] = [:]
      let dates = Date.between(startDate, endDate)
      for date in dates {
        // 로컬에 저장된 데이터가 없는 경우 네트워킹 통하여 가져옴
        guard let savedIntake = savedIntakePerDate[date] else {
          self.dustAPIService.dayInfo(from: date, to: endDate)
            .subscribe(
              onNext: { hourlyDustIntakePerDate in
                self.healthKitService.todayDistancePerHour(from: date, to: endDate)
                  .subscribe(
                    onNext: { hourlyDistancePerDate in
                      let savedIntake = savedIntakePerDate.sort().map { $0.value }
                      let savedFineDustIntake = savedIntake.compactMap { $0.fineDust }
                      let savedUltraFineDustIntake = savedIntake.compactMap { $0.ultraFineDust }
                      let dustIntakes = self.totalHourlyIntakes(hourlyDustIntakePerDate,
                                                                hourlyDistancePerDate)
                      let totalFineDustIntakes
                        = [savedFineDustIntake, dustIntakes.fineDust].flatMap { $0 }
                      let totalUltraFineDustIntakes
                        = [savedUltraFineDustIntake, dustIntakes.ultraFineDust].flatMap { $0 }
                      let intakes = zip(totalFineDustIntakes, totalUltraFineDustIntakes)
                        .map { DustPair(fineDust: $0, ultraFineDust: $1) }
                      self.persistenceService.saveIntakes(intakes, at: dates)
                      observer.onNext(intakes)
                      observer.onCompleted()
                  }, onError: { error in
                    observer.onError(error)
                  })
                  .disposed(by: self.disposeBag)
            }, onError: { error in
              observer.onError(error)
            })
            .disposed(by: self.disposeBag)
          return Disposables.create()
        }
        // 로컬에 저장된 데이터가 있는 경우
        fineDustIntakePerDate[date] = savedIntake.fineDust
        ultraFineDustIntakePerDate[date] = savedIntake.ultraFineDust
      }
      let totalFineDustIntakes = fineDustIntakePerDate.sort().map { $0.value }
      let totalUltraFineDustIntakes = ultraFineDustIntakePerDate.sort().map { $0.value }
      let element = zip(totalFineDustIntakes, totalUltraFineDustIntakes)
        .map { DustPair(fineDust: $0, ultraFineDust: $1) }
      observer.onNext(element)
      observer.onCompleted()
      return Disposables.create()
    }
  }
}

private extension IntakeService {
  
  func intakePerHour(dust: Int, distance: Int) -> Int {
    return Int(Double(dust * distance) * 0.036 * 0.01)
  }
  
  /// 시간별 흡입량 계산.
  func totalHourlyIntake(_ hourlyDustIntake: DustPair<[Hour: Int]>,
                         _ hourlyDistance: [Hour: Int]) -> DustPair<Int> {
    let sortedFineDust = hourlyDustIntake.fineDust.sort().map { $0.value }
    let sortedUltraFineDust = hourlyDustIntake.ultraFineDust.sort().map { $0.value }
    let sortedDistance = hourlyDistance.sort().map { $0.value }
    let fineDust = zip(sortedFineDust, sortedDistance)
      .reduce(0) { $0 + intakePerHour(dust: $1.0, distance: $1.1) }
    let ultraFineDust = zip(sortedUltraFineDust, sortedDistance)
      .reduce(0) { $0 + intakePerHour(dust: $1.0, distance: $1.1) }
    return .init(fineDust: fineDust, ultraFineDust: ultraFineDust)
  }
  
  /// 날짜별 시간별 총 흡입량 계산.
  func totalHourlyIntakes(_ hourlyDustIntakePerDate: DustPair<[Date: [Hour: Int]]>,
                          _ hourlyDistancePerDate: [Date: [Hour: Int]]) -> DustPair<[Int]> {
    var fineDusts: [Int] = []
    var ultrafineDusts: [Int] = []
    let sortedHourlyFineDustIntakePerDate = hourlyDustIntakePerDate.fineDust.sort()
    let sortedHourlyUltraㄹineDustIntakePerDate = hourlyDustIntakePerDate.ultraFineDust.sort()
    let sortedHourlyDistancePerDate = hourlyDistancePerDate.sort()
    zip(sortedHourlyFineDustIntakePerDate, sortedHourlyDistancePerDate).forEach {
      let (hourlyFineDustIntakePerDate, hourlyDistancePerDate) = $0
      let sortedHourlyFineDustIntake = hourlyFineDustIntakePerDate.value.sort()
      let sortedHourlyDistance = hourlyDistancePerDate.value.sort()
      let intake = zip(sortedHourlyFineDustIntake, sortedHourlyDistance)
        .reduce(0) { $0 + intakePerHour(dust: $1.0.value, distance: $1.1.value) }
      fineDusts.append(intake)
    }
    zip(sortedHourlyUltraㄹineDustIntakePerDate, sortedHourlyDistancePerDate).forEach {
      let (hourlyUltrafineDustIntakePerDate, hourlyDistancePerDate) = $0
      let sortedHourlyUltraㄹineDustIntake = hourlyUltrafineDustIntakePerDate.value.sort()
      let sortedHourlyDistance = hourlyDistancePerDate.value.sort()
      let intake = zip(sortedHourlyUltraㄹineDustIntake, sortedHourlyDistance)
        .reduce(0) { $0 + intakePerHour(dust: $1.0.value, distance: $1.1.value) }
      ultrafineDusts.append(intake)
    }
    return .init(fineDust: fineDusts, ultraFineDust: ultrafineDusts)
  }
}
