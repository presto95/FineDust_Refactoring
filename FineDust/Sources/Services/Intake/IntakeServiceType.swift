//
//  IntakeManagerType.swift
//  FineDust
//
//  Created by Presto on 30/01/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import RxSwift

protocol IntakeServiceType {
  
  func todayIntake() -> Single<Result<DustPair<Int>, Error>>
  
  func weekIntake() -> Single<Result<[DustPair<Int>], Error>>
}
