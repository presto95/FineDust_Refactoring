//
//  LocationResult.swift
//  FineDust
//
//  Created by Presto on 25/07/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import RxRelay

final class LocationObserver {
  
  static let shared = LocationObserver()
  
  private init() { }
  
  let didSuccess = PublishRelay<Void>()
  
  let didError = PublishRelay<Error>()
  
  let didAuthorizationDenied = PublishRelay<Void>()
}
