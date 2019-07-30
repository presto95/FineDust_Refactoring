//
//  LocationManager.swift
//  FineDust
//
//  Created by Presto on 30/01/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import CoreLocation
import Foundation

import RxCoreLocation
import RxSwift

final class LocationManager: NSObject {
  
  fileprivate let locationManager = CLLocationManager().then {
    $0.desiredAccuracy = kCLLocationAccuracyBest
    $0.distanceFilter = kCLDistanceFilterNone
  }
  
  static let shared = LocationManager()
  
  private override init() { }
}

// MARK: - Implement LocationManagerType

extension LocationManager: LocationManagerType {
  
  var authorizationStatus: CLAuthorizationStatus {
    return CLLocationManager.authorizationStatus()
  }
  
  func requestAuthorization() {
    locationManager.requestAlwaysAuthorization()
  }
  
  func startUpdatingLocation() {
    locationManager.startUpdatingLocation()
  }
  
  func stopUpdatingLocation() {
    locationManager.stopUpdatingLocation()
  }
}

// MARK: - Reactive Extension

extension Reactive where Base: LocationManager {
  
  var authorizationStatus: Observable<CLAuthorizationStatus> {
    return base.locationManager.rx.didChangeAuthorization
      .map { $0.status }
  }
  
  var location: Observable<CLLocation> {
    return base.locationManager.rx.didUpdateLocations
      .map { $0.locations.first }
      .filterNil()
  }
  
  var error: Observable<Error> {
    return base.locationManager.rx.didError
      .map { $0.error }
  }
}
