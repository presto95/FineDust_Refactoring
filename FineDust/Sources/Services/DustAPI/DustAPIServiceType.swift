//
//  DustAPIServiceType.swift
//  FineDust
//
//  Created by Presto on 24/07/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import Foundation

import RxSwift

protocol DustAPIServiceType: class {
  
  func requestObservatory() -> Observable<DustAPIObservatoryResponse>
  
  func requestRecentTimeInfo() -> Observable<RecentDustInfo>
  
  func requestDayInfo() -> Observable<(HourIntakePair, HourIntakePair)>
  
  func requestDayInfo(from startDate: Date, to endDate: Date) -> Observable<(DateHourIntakePair, DateHourIntakePair)>
}
