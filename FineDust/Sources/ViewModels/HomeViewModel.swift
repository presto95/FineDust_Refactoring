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
  
  var address: Observable<String> { get }
  
  var grade: Observable<DustGrade> { get }
  
  var recentFineDustValue: Observable<Int> { get }
}

final class HomeViewModel {
  
  private let isPresentedRelay = BehaviorRelay(value: false)
  
  private let authorizationButtonTappedRelay = PublishRelay<Void>()
  
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
}

extension HomeViewModel {
  
  var inputs: HomeViewModelInputs { return self }

  var outputs: HomeViewModelOutputs { return self }
}

// MARK: - Private Method

private extension HomeViewModel {
  
  
  
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
