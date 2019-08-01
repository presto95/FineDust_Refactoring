//
//  RatioGraphViewModel.swift
//  FineDust
//
//  Created by Presto on 21/07/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import RxRelay
import RxSwift

protocol RatioGraphViewModelInputs {
  
  func setIntakeRatio(_ intakeRatio: Double)
  
  func setTotalIntake(_ totalIntake: Int)
  
  func setTodayIntake(_ todayIntake: Int)
}

protocol RatioGraphViewModelOutputs {
  
  var pieGraphViewDataSource: Observable<(ratio: Double, endAngle: Double)> { get }
  
  var stickGraphViewDataSource: Observable<(averageIntake: Int, todayIntake: Int)> { get }
}

final class RatioGraphViewModel {
  
  private let intakeRatioRelay = BehaviorRelay<Double>(value: 0)
  
  private let totalIntakeRelay = BehaviorRelay<Int>(value: 0)
  
  private let todayIntakeRelay = BehaviorRelay<Int>(value: 0)
}

extension RatioGraphViewModel: RatioGraphViewModelInputs {
  
  func setIntakeRatio(_ intakeRatio: Double) {
    intakeRatioRelay.accept(intakeRatio)
  }
  
  func setTotalIntake(_ totalIntake: Int) {
    totalIntakeRelay.accept(totalIntake)
  }
  
  func setTodayIntake(_ todayIntake: Int) {
    todayIntakeRelay.accept(todayIntake)
  }
}

extension RatioGraphViewModel: RatioGraphViewModelOutputs {
  
  var pieGraphViewDataSource: Observable<(ratio: Double, endAngle: Double)> {
    return intakeRatioRelay.asObservable()
      .map { ($0, $0 * 2 * .pi - .pi / 2) }
  }
  
  var stickGraphViewDataSource: Observable<(averageIntake: Int, todayIntake: Int)> {
    return Observable
      .zip(totalIntakeRelay.asObservable(), todayIntakeRelay.asObservable()) { ($0, $1) }
  }
}
