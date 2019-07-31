//
//  StickGraphViewModel.swift
//  FineDust
//
//  Created by Presto on 21/07/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import RxRelay
import RxSwift

protocol StickGraphViewModelInputs {
  
  func setIntakes(_ intakes: [Int])
}

protocol StickGraphViewModelOutputs {
  
  var weekIntake: Observable<[Int]> { get }
  
  var maxIntake: Observable<Int> { get }
  
  var intakeRatios: Observable<[Double]> { get }
  
  var axisTexts: Observable<[String]> { get }
  
  var dayTexts: Observable<[String]> { get }
  
  var date: Observable<String> { get }
}

final class StickGraphViewModel {
  
  private let intakesRelay = PublishRelay<[Int]>()
}

extension StickGraphViewModel: StickGraphViewModelInputs {
  
  func setIntakes(_ intakes: [Int]) {
    intakesRelay.accept(intakes)
  }
}

extension StickGraphViewModel: StickGraphViewModelOutputs {
  
  var weekIntake: Observable<[Int]> {
    return intakesRelay.asObservable()
  }
  
  var maxIntake: Observable<Int> {
    return intakesRelay.asObservable()
      .map { $0.max() ?? 1 }
  }
  
  var intakeRatios: Observable<[Double]> {
    return Observable.zip(weekIntake, maxIntake) { weekIntake, maxIntake in
      weekIntake.map { 1.0 - Double($0) / Double(maxIntake) }
        .map { !$0.canBecomeMultiplier ? 0.01 : $0 }
    }
  }
  
  var axisTexts: Observable<[String]> {
    return maxIntake
      .map { ["\(Int($0))", "\(Int($0 / 2))", "0"] }
  }
  
  var dayTexts: Observable<[String]> {
    let dateFormatter = DateFormatter.day
    var array = [Date](repeating: .init(), count: 7)
    for (index, element) in array.enumerated() {
      array[index] = element.before(days: index)
    }
    var reversed = Array(array.map { dateFormatter.string(from: $0) }.reversed())
    reversed.removeLast()
    reversed.append("오늘")
    return .just(reversed)
  }
  
  var date: Observable<String> {
    return .just(DateFormatter.dateDay.string(from: .init()))
  }
}
