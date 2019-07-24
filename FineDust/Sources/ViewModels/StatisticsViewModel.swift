//
//  StatisticsViewModel.swift
//  FineDust
//
//  Created by Presto on 21/07/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import RxRelay
import RxSwift

protocol StatisticsViewModelInputs {
  
  func selectSegmentedControl(at index: Int)
}

protocol StatisticsViewModelOutputs {
  
  var selectedSegmentedControlIndex: Observable<Int> { get }
}

final class StatisticsViewModel {
  
  private let selectedSegmentedControlIndexRelay = BehaviorRelay(value: 0)
  
  private let disposeBag = DisposeBag()
  
  private let intakeService: IntakeServiceType
  
  private let persistenceService: PersistenceServiceType
  
  init(intakeService: IntakeServiceType = IntakeService(),
       persistenceService: PersistenceServiceType = PersistenceService()) {
    self.intakeService = intakeService
    self.persistenceService = persistenceService
  }
}

extension StatisticsViewModel: StatisticsViewModelInputs {
  
  func selectSegmentedControl(at index: Int) {
    selectedSegmentedControlIndexRelay.accept(index)
  }
}

extension StatisticsViewModel: StatisticsViewModelOutputs {
  
  var selectedSegmentedControlIndex: Observable<Int> {
    return selectedSegmentedControlIndexRelay.asObservable()
  }
}

extension StatisticsViewModel {
  
  var inputs: StatisticsViewModelInputs { return self }
  
  var outputs: StatisticsViewModelOutputs { return self }
}

// MARK: - Private Method

private extension StatisticsViewModel {
  
  func requestIntake() {
    intakeService.requestIntakesInWeek()
      .subscribe(
        onNext: { dustIntakes in
          <#code#>
      }, onError: { error in
        <#code#>
      })
      .disposed(by: disposeBag)
  }
}
