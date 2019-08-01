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
  
  func setPresented()
  
  func updateData()
  
  func selectSegmentedControl(at index: Int)
}

protocol StatisticsViewModelOutputs {
  
  var isPresented: Observable<Bool> { get }
  
  var selectedSegmentedControlIndex: Observable<Int> { get }
  
  var intakeData: Observable<IntakeData> { get }
  
  var todayDustRatio: Observable<DustPair<Double>> { get }
}

final class StatisticsViewModel {
  
  private let disposeBag = DisposeBag()
  
  private let isPresentedRelay = BehaviorRelay<Bool>(value: false)
  
  private let selectedSegmentedControlIndexRelay = BehaviorRelay(value: 0)
  
  private let intakeDataRelay = PublishRelay<IntakeData>()
  
  private let intakeService: IntakeServiceType
  
  private let persistenceService: PersistenceServiceType
  
  init(intakeService: IntakeServiceType = IntakeService(),
       persistenceService: PersistenceServiceType = PersistenceService()) {
    self.intakeService = intakeService
    self.persistenceService = persistenceService
  }
}

extension StatisticsViewModel: StatisticsViewModelInputs {
  
  func setPresented() {
    isPresentedRelay.accept(true)
    fetchLastSavedData()
  }
  
  func updateData() {
    requestIntakeData().bind(to: intakeDataRelay).disposed(by: disposeBag)
  }
  
  func selectSegmentedControl(at index: Int) {
    selectedSegmentedControlIndexRelay.accept(index)
  }
}

extension StatisticsViewModel: StatisticsViewModelOutputs {
  
  var isPresented: Observable<Bool> {
    return isPresentedRelay.asObservable()
  }
  
  var selectedSegmentedControlIndex: Observable<Int> {
    return selectedSegmentedControlIndexRelay.asObservable()
  }
  
  var intakeData: Observable<IntakeData> {
    return intakeDataRelay.asObservable()
  }
  
  var todayDustRatio: Observable<DustPair<Double>> {
    return intakeData
      .map { $0.weekDust }
      .map { DustPair(fineDust: $0.map { $0.fineDust },
                      ultraFineDust: $0.map { $0.ultraFineDust }) }
      .map {
        let reduced = DustPair(fineDust: $0.fineDust.reduce(0, +),
                               ultraFineDust: $0.ultraFineDust.reduce(0, +))
        let sum = DustPair(fineDust: reduced.fineDust == 0 ? 1 : reduced.fineDust,
                           ultraFineDust: reduced.ultraFineDust == 0 ? 1 : reduced.ultraFineDust)
        let last = DustPair(fineDust: $0.fineDust.last ?? 1,
                            ultraFineDust: $0.ultraFineDust.last ?? 1)
        return DustPair(fineDust: Double(last.fineDust) / Double(sum.fineDust),
                        ultraFineDust: Double(last.ultraFineDust) / Double(sum.ultraFineDust))
    }
  }
}

// MARK: - Private Method

private extension StatisticsViewModel {
  
  func requestIntakeData() -> Observable<IntakeData> {
    let todayIntakeObservable = intakeService.todayIntake()
    let weekIntakeObservable = intakeService.weekIntake()
    return Observable
      .zip(todayIntakeObservable, weekIntakeObservable) { todayIntake, weekIntake in
        IntakeData(weekDust: weekIntake, todayDust: todayIntake)
      }
      .do(onNext: { intakeData in
        let weekIntake = intakeData.weekDust
        let todayIntake = intakeData.todayDust
        let fineDust = [weekIntake.map { $0.fineDust }, [todayIntake.fineDust]].flatMap { $0 }
        let ultraFineDust
          = [weekIntake.map { $0.ultraFineDust }, [todayIntake.ultraFineDust]].flatMap { $0 }
        let intakes = zip(fineDust, ultraFineDust)
          .map { DustPair(fineDust: $0, ultraFineDust: $1) }
        self.persistenceService.saveLastWeekIntake(intakes)
      })
  }
  
  func fetchLastSavedData() {
    guard let lastSavedData = persistenceService.lastSavedData() else { return }
    let intakeData = IntakeData(weekDust: lastSavedData.weekDust,
                                todayDust: lastSavedData.todayDust)
    intakeDataRelay.accept(intakeData)
  }
}
