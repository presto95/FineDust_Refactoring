//
//  HealthKitServiceType.swift
//  FineDust
//
//  Created by Presto on 25/07/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import Foundation

import RxSwift

protocol HealthKitServiceType: class {
  
  var isAuthorized: Bool { get }
  
  func requestAuthorization() -> Single<Result<Bool, Error>>
  
  func todayStepCount() -> Single<Result<Double, Error>>
  
  func todayDistance() -> Single<Result<Double, Error>>
  
  func todayDistancePerHour() -> Single<Result<[Hour: Int], Error>>
  
  func todayDistancePerHour(from startDate: Date,
                            to endDate: Date) -> Single<Result<[Date: [Hour: Int]], Error>>
}

