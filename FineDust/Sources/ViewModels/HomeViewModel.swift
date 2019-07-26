//
//  HomeViewModel.swift
//  FineDust
//
//  Created by Presto on 25/07/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import RxRelay
import RxSwift

protocol HomeViewModelInputs {
  
  func setPresented()
  
  func tapAuthorizationButton()
  
  func tapHealthAppOpeningButton()
  
  func tapSettingAppOpeningButton()
}

protocol HomeViewModelOutputs {
  
  var authorizationButtonTapped: Observable<Void> { get }
  
  var todayFineDustValue: Observable<Int> { get }
  
  var todayUltraFineDustValue: Observable<Int> { get }
  
  var intakeGrade: Observable<IntakeGrade> { get }
  
  var steps: Observable<Int> { get }
  
  var distance: Observable<Int> { get }
  
  var address: Observable<String> { get }
  
  var grade: Observable<DustGrade> { get }
  
  var recentFineDustValue: Observable<Int> { get }
}

final class HomeViewModel {
  
  private let disposeBag = DisposeBag()
  
  private let isPresentedRelay = BehaviorRelay(value: false)
  
  private let authorizationButtonTappedRelay = PublishRelay<Void>()
  
  private let stepsRelay = PublishRelay<Int>()
  
  private let distanceRelay = PublishRelay<Int>()
  
  private let addressRelay = PublishRelay<String>()
  
  private let gradeRelay = PublishRelay<DustGrade>()
  
  private let recentFineDustValueRelay = PublishRelay<Int>()
  
  private let locationObserver = LocationObserver.shared
  
  private let healthKitObserver = HealthKitObserver.shared
  
  private let persistenceService: PersistenceServiceType
  
  private let healthKitService: HealthKitServiceType
  
  private let dustAPIService: DustAPIServiceType
  
  private let intakeService: IntakeServiceType
  
  private let locationManager: LocationManagerType
  
  init(persistenceService: PersistenceServiceType = PersistenceService(),
       healthKitService: HealthKitServiceType = HealthKitService(),
       dustAPIService: DustAPIServiceType = DustAPIService(),
       intakeService: IntakeServiceType = IntakeService(),
       locationManager: LocationManagerType = LocationManager()) {
    self.persistenceService = persistenceService
    self.healthKitService = healthKitService
    self.dustAPIService = dustAPIService
    self.intakeService = intakeService
    self.locationManager = locationManager
  }
}

extension HomeViewModel: HomeViewModelInputs {
  
  func setPresented() {
    isPresentedRelay.accept(true)
  }
  
  func tapAuthorizationButton() {
    authorizationButtonTappedRelay.accept(Void())
  }
  
  func tapHealthAppOpeningButton() {
    openHealthApp()
  }
  
  func tapSettingAppOpeningButton() {
    openSettingApp()
  }
}

extension HomeViewModel: HomeViewModelOutputs {

  var authorizationButtonTapped: Observable<Void> {
    return authorizationButtonTappedRelay.asObservable()
  }
  
  var todayFineDustValue: Observable<Int> {
    
  }
  
  var todayUltraFineDustValue: Observable<Int> {
    
  }
  
  var intakeGrade: Observable<IntakeGrade> {
    
  }
  
  var steps: Observable<Int> {
    return stepsRelay.asObservable()
  }
  
  var distance: Observable<Int> {
    
  }
  
  var address: Observable<String> {
    
  }
  
  var grade: Observable<DustGrade> {
    
  }
  
  var recentFineDustValue: Observable<Int> {
    
  }
}

// MARK: - Private Method

private extension HomeViewModel {
  
  func updateHealthKitData() {
    healthKitService.todaySteps()
      .subscribe(onNext: { steps in
        self.persistenceService.saveLastSteps(Int(steps))
        self.stepsRelay.accept(Int(steps))
      }, onError: { error in
        // Todo: error handling
        self.stepsRelay.accept(0)
      })
      .disposed(by: disposeBag)
  }
  
  func openHealthApp() {
    guard let url = URL(string: "x-apple-health://") else { return }
    openURL(url)
  }
  
  func openSettingApp() {
    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
    openURL(url)
  }
  
  func openURL(_ url: URL) {
    if UIApplication.shared.canOpenURL(url) {
      UIApplication.shared.open(url)
    }
  }
}
