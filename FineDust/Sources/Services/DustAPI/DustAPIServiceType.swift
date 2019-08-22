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
  
  func observatory() -> Single<Result<String, Error>>
  
  func recentTimeInfo() -> Single<Result<RecentDustInfo, Error>>
  
  func dayInfo() -> Single<Result<DustPair<[Hour: Int]>, Error>>
  
  func dayInfo(from startDate: Date,
               to endDate: Date) -> Single<Result<DustPair<[Date: [Hour: Int]]>, Error>>
}
