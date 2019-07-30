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
  
  func requestAuthorization() -> Observable<Bool>
  
  func todaySteps() -> Observable<Double>
  
  func todayDistance() -> Observable<Double>
  
  func todayDistancePerHour() -> Observable<[Hour: Int]>
  
  func todayDistancePerHour(from startDate: Date,
                            to endDate: Date) -> Observable<[Date: [Hour: Int]]>
}

