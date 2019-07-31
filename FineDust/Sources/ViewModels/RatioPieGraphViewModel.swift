//
//  RatioPieGraphViewModel.swift
//  FineDust
//
//  Created by Presto on 31/07/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import RxRelay
import RxSwift

protocol RatioPieGraphViewModelInputs {
  
  func setValues(ratio: Double, endAngle: Double)
}

protocol RatioPieGraphViewModelOutputs {
  
  var valuesUpdated: Observable<(ratio: Double, endAngle: Double)> { get }
}

final class RatioPieGraphViewModel {
  
  private let ratioRelay = BehaviorRelay<Double>(value: 0)
  
  private let endAngleRelay = BehaviorRelay<Double>(value: 0)
}

extension RatioPieGraphViewModel: RatioPieGraphViewModelInputs {
  
  func setValues(ratio: Double, endAngle: Double) {
    ratioRelay.accept(ratio)
    endAngleRelay.accept(endAngle)
  }
}

extension RatioPieGraphViewModel: RatioPieGraphViewModelOutputs {
  
  var valuesUpdated: Observable<(ratio: Double, endAngle: Double)> {
    return Observable.zip(ratioRelay.asObservable(), endAngleRelay.asObservable()) { ($0, $1) }
  }
}
