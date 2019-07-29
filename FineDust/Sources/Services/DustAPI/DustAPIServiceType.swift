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
  
  func observatory() -> Observable<String>
  
  func recentTimeInfo() -> Observable<RecentDustInfo>
  
  func dayInfo() -> Observable<DustPair<HourIntakePair>>
  
  func dayInfo(from startDate: Date, to endDate: Date) -> Observable<DustPair<DateHourIntakePair>>
}
