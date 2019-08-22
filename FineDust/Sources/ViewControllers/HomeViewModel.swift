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
  
  func fetchLastSavedData()
  
  func setPresented()
  
  func updateDustData()
  
  func updateHealthKitData()
  
  func tapAuthorizationButton()
  
  func tapHealthAppOpeningButton()
  
  func tapSettingAppOpeningButton()
}

protocol HomeViewModelOutputs {
  
  var isPresented: Observable<Bool> { get }
  
  var authorizationButtonTapped: Observable<(isHealthKitAuthorized: Bool, isLocationAuthorized: Bool)> { get }
  
  var todayIntake: Observable<DustPair<Int>> { get }
  
  var fineDustImageName: Observable<String> { get }
  
  var time: Observable<String> { get }
  
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
  
  private let intakeRelay = PublishRelay<DustPair<Int>>()
  
  private let stepsRelay = PublishRelay<Int>()
  
  private let distanceRelay = PublishRelay<Int>()
  
  private let addressRelay = PublishRelay<String>()
  
  private let gradeRelay = PublishRelay<DustGrade>()
  
  private let recentFineDustValueRelay = PublishRelay<Int>()
  
  private let persistenceService: PersistenceServiceType
  
  private let healthKitService: HealthKitServiceType
  
  private let dustAPIService: DustAPIServiceType
  
  private let intakeService: IntakeServiceType
  
  private let locationManager: LocationManagerType
  
  init(persistenceService: PersistenceServiceType = PersistenceService(),
       healthKitService: HealthKitServiceType = HealthKitService(),
       dustAPIService: DustAPIServiceType = DustAPIService(),
       intakeService: IntakeServiceType = IntakeService(),
       locationManager: LocationManagerType = LocationManager.shared) {
    self.persistenceService = persistenceService
    self.healthKitService = healthKitService
    self.dustAPIService = dustAPIService
    self.intakeService = intakeService
    self.locationManager = locationManager
  }
}

extension HomeViewModel: HomeViewModelInputs {
  
  func fetchLastSavedData() {
    guard let lastSavedData = persistenceService.lastSavedData() else { return }
    stepsRelay.accept(lastSavedData.steps)
    distanceRelay.accept(Int(lastSavedData.distance))
    addressRelay.accept(lastSavedData.address)
    gradeRelay.accept(DustGrade(rawValue: lastSavedData.grade) ?? .default)
    recentFineDustValueRelay.accept(lastSavedData.recentFineDust)
  }
  
  func setPresented() {
    isPresentedRelay.accept(true)
  }
  
  func updateDustData() {
    updateRecentDustData()
    updateTodayIntake()
  }
  
  func updateHealthKitData() {
    updateSteps()
    updateDistance()
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
  
  var isPresented: Observable<Bool> {
    return isPresentedRelay.asObservable()
  }
  
  var authorizationButtonTapped: Observable<(isHealthKitAuthorized: Bool, isLocationAuthorized: Bool)> {
    let isHealthKitAuthorized = Observable.just(healthKitService.isAuthorized)
    let isLocationAuthorized = Observable.just(locationManager.authorizationStatus == .authorizedAlways
      || locationManager.authorizationStatus == .authorizedWhenInUse)
    let isAuthorized = Observable.zip(isHealthKitAuthorized, isLocationAuthorized) { ($0, $1) }
      .map { (isHealthKitAuthorized: $0, isLocationAuthorized: $1) }
    return authorizationButtonTappedRelay.asObservable()
      .withLatestFrom(isAuthorized)
  }
  
  var todayIntake: Observable<DustPair<Int>> {
    return intakeRelay.asObservable()
  }
  
  var fineDustImageName: Observable<String> {
    return todayIntake
      .map { IntakeGrade(rawValue: $0.fineDust + $0.ultraFineDust) ?? .default }
      .map { $0.imageName }
  }
  
  var time: Observable<String> {
    return .just(DateFormatter.time.string(from: .init()))
  }
  
  var steps: Observable<Int> {
    return stepsRelay.asObservable()
  }
  
  var distance: Observable<Int> {
    return distanceRelay.asObservable()
  }
  
  var address: Observable<String> {
    return addressRelay.asObservable()
  }
  
  var grade: Observable<DustGrade> {
    return gradeRelay.asObservable()
  }
  
  var recentFineDustValue: Observable<Int> {
    return recentFineDustValueRelay.asObservable()
  }
}

// MARK: - Private Method

private extension HomeViewModel {
  
  func updateRecentDustData() {
    dustAPIService.recentTimeInfo()
      .do(onNext: { recentInfo in
        self.persistenceService.saveLastDustData(address: SharedInfo.shared.address,
                                                 grade: recentInfo.dustGrade.fineDust.rawValue,
                                                 recentFineDust: recentInfo.dustValue.fineDust)
      })
      .subscribe(
        onNext: { recentInfo in
          self.addressRelay.accept(SharedInfo.shared.address)
          self.recentFineDustValueRelay.accept(recentInfo.dustValue.fineDust)
          self.gradeRelay.accept(recentInfo.dustGrade.fineDust)
      }, onError: { error in
        // Todo: error handling
        Log.error(error)
      })
      .disposed(by: disposeBag)
  }
  
  func updateTodayIntake() {
    intakeService.todayIntake()
      .do(onNext: { todayIntake in
        self.persistenceService.saveLastTodayIntake(todayIntake)
      })
      .subscribe(
        onNext: { todayIntake in
          self.intakeRelay.accept(todayIntake)
      }, onError: { error in
        // Todo: error handling
        Log.error(error)
      })
      .disposed(by: disposeBag)
  }
  
  func updateSteps() {
    healthKitService.todaySteps()
      .do(onNext: { steps in self.persistenceService.saveLastSteps(Int(steps)) })
      .subscribe(
        onNext: { steps in
          self.stepsRelay.accept(Int(steps))
      }, onError: { error in
        // Todo: error handling
        Log.error(error)
        self.stepsRelay.accept(0)
      })
      .disposed(by: disposeBag)
  }
  
  func updateDistance() {
    healthKitService.todayDistance()
      .do(onNext: { distance in self.persistenceService.saveLastDistance(distance) })
      .subscribe(
        onNext: { distance in
          self.distanceRelay.accept(Int(distance))
      }, onError: { error in
        // Todo: error handling
        Log.error(error)
        self.distanceRelay.accept(0)
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
