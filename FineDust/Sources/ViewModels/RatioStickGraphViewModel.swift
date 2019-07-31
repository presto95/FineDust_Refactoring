//
//  RatioStickGraphViewModel.swift
//  FineDust
//
//  Created by Presto on 31/07/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import RxRelay
import RxSwift

protocol RatioStickGraphViewModelInputs {
  
  func setIntakeValues(_ averageIntake: Int, _ todayIntake: Int)
}

protocol RatioStickGraphViewModelOutputs {
  
  var intakeValuesUpdated: Observable<(averageIntake: Int, todayIntake: Int)> { get }
}

final class RatioStickGraphViewModel {
  
  private let averageIntakeRelay = BehaviorRelay<Int>(value: 0)
  
  private let todayIntakeRelay = BehaviorRelay<Int>(value: 0)
}

extension RatioStickGraphViewModel: RatioStickGraphViewModelInputs {
  
  func setIntakeValues(_ averageIntake: Int, _ todayIntake: Int) {
    averageIntakeRelay.accept(averageIntake)
    todayIntakeRelay.accept(todayIntake)
  }
}

extension RatioStickGraphViewModel: RatioStickGraphViewModelOutputs {

  var intakeValuesUpdated: Observable<(averageIntake: Int, todayIntake: Int)> {
    return Observable.zip(averageIntakeRelay.asObservable(),
                          todayIntakeRelay.asObservable()) { ($0, $1) }
  }
}
