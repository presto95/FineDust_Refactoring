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
  
  private let disposeBag = DisposeBag()
  
  private let geocodeService: GeocodeServiceType
  
  private let dustAPIService: DustAPIServiceType
  
  private let locationManager = CLLocationManager().then {
    $0.desiredAccuracy = kCLLocationAccuracyBest
    $0.distanceFilter = kCLDistanceFilterNone
  }
  
  init(geocodeService: GeocodeServiceType = GeocodeService(),
       dustAPIService: DustAPIServiceType = DustAPIService()) {
    super.init()
    self.geocodeService = geocodeService
    self.dustAPIService = dustAPIService
    
    locationManager.rx.didChangeAuthorization
      .map { $0.status }
      .subscribe(onNext: authorizationDidChange)
      .disposed(by: disposeBag)
    
    locationManager.rx.didUpdateLocations
      .map { $0.locations.first }
      .subscribe(onNext: locationDidUpdate)
      .disposed(by: disposeBag)
    
    locationManager.rx.didError
      .map { $0.error }
      .subscribe(onNext: errorHandler)
      .disposed(by: disposeBag)
  }
}

// MARK: - Implement LocationManagerType

extension LocationManager: LocationManagerType {
  
  var authorizationStatus: CLAuthorizationStatus {
    return CLLocationManager.authorizationStatus()
  }
  
  var authorizationDidChange: ((CLAuthorizationStatus) -> Void)? {
    return { status in
      switch status {
      case .authorizedAlways, .authorizedWhenInUse:
        self.startUpdatingLocation()
      default:
        LocationObserver.shared.didAuthorizationDenied.accept(Void())
      }
    }
  }
  
  var locationDidUpdate: ((CLLocation?) -> Void)? {
    return { [weak self] location in
      guard let self = self else { return }
      guard let location = location else { return }
      self.stopUpdatingLocation()
      let coordinate = location.coordinate
      let convertedCoordinate
        = GeoConverter().convert(sourceType: .WGS_84,
                                 destinationType: .TM,
                                 geoPoint: .init(x: coordinate.longitude,
                                                 y: coordinate.latitude))
      SharedInfo.shared.x = convertedCoordinate?.x ?? 0
      SharedInfo.shared.y = convertedCoordinate?.y ?? 0
      
      self.geocodeService.geocode(for: location)
        .do(onNext: { address in SharedInfo.shared.address = address })
        .withLatestFrom(self.dustAPIService.observatory())
        .subscribe(
          onNext: { observatory in
            SharedInfo.shared.observatory = observatory
            LocationObserver.shared.didSuccess.accept(Void())
        }, onError: { error in
          LocationObserver.shared.didError.accept(error)
        })
        .disposed(by: self.disposeBag)
    }
  }
  
  var errorHandler: ((Error) -> Void)? {
    return { error in
      LocationObserver.shared.didError.accept(error)
    }
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
