//
//  HomeInfoViewModel.swift
//  FineDust
//
//  Created by Presto on 25/07/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import RxSwift
import RxRelay

protocol HomeInfoViewModelInputs {
  
  func setDistance(_ distance: Int)
  
  func setSteps(_ steps: Int)
  
  func setTime(_ time: String)
  
  func setAddress(_ address: String)
  
  func setDustValue(_ value: Int)
  
  func setDustGrade(_ grade: DustGrade)
}

protocol HomeInfoViewModelOutputs {
  
  var distance: Observable<Int> { get }
  
  var steps: Observable<Int> { get }
  
  var time: Observable<String> { get }
  
  var address: Observable<String> { get }
  
  var dustValue: Observable<Int> { get }
  
  var dustGrade: Observable<DustGrade> { get }
}

final class HomeInfoViewModel {
  
  private let distanceRelay = PublishRelay<Int>()
  
  private let stepsRelay = PublishRelay<Int>()
  
  private let timeRelay = PublishRelay<String>()
  
  private let addressRelay = PublishRelay<String>()
  
  private let dustValueRelay = PublishRelay<Int>()
  
  private let dustGradeRelay = PublishRelay<DustGrade>()
}

extension HomeInfoViewModel: HomeInfoViewModelInputs {
  
  func setDistance(_ distance: Int) {
    distanceRelay.accept(distance)
  }
  
  func setSteps(_ steps: Int) {
    stepsRelay.accept(steps)
  }
  
  func setTime(_ time: String) {
    timeRelay.accept(time)
  }
  
  func setAddress(_ address: String) {
    addressRelay.accept(address)
  }
  
  func setDustValue(_ value: Int) {
    dustValueRelay.accept(value)
  }
  
  func setDustGrade(_ grade: DustGrade) {
    dustGradeRelay.accept(grade)
  }
}

extension HomeInfoViewModel: HomeInfoViewModelOutputs {
  
  var distance: Observable<Int> {
    return distanceRelay.asObservable()
  }
  
  var steps: Observable<Int> {
    return stepsRelay.asObservable()
  }
  
  var time: Observable<String> {
    return timeRelay.asObservable()
  }
  
  var address: Observable<String> {
    return addressRelay.asObservable()
  }
  
  var dustValue: Observable<Int> {
    return dustValueRelay.asObservable()
  }
  
  var dustGrade: Observable<DustGrade> {
    return dustGradeRelay.asObservable()
  }
}
