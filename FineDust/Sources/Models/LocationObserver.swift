//
//  LocationResult.swift
//  FineDust
//
//  Created by Presto on 25/07/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import RxRelay
import RxSwift

final class LocationObserver {
  
  static let shared = LocationObserver()
  
  private init() { }
  
  private let didSuccessRelay = BehaviorRelay<Void?>(value: nil)
  
  private let didErrorRelay = BehaviorRelay<Error?>(value: nil)
  
  private let didAuthorizationDeniedRelay = BehaviorRelay<Void?>(value: nil)
}

extension LocationObserver {

  func didSuccess() {
    didSuccessRelay.accept(Void())
  }
  
  func didError(_ error: Error) {
    didErrorRelay.accept(error)
  }
  
  func didAuthorizationDenied() {
    didAuthorizationDeniedRelay.accept(Void())
  }
  
  var success: Observable<Void> {
    return didSuccessRelay.filterNil()
  }
  
  var error: Observable<Error> {
    return didErrorRelay.filterNil()
  }
  
  var authorizationDenied: Observable<Void> {
    return didAuthorizationDeniedRelay.filterNil()
  }
}
