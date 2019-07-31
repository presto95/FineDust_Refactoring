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
  
}
