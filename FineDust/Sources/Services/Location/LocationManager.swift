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
        NotificationCenter.default
          .post(name: .locationPermissionDenied, object: nil, userInfo: ["status": status])
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
        .subscribe(
          onNext: { address in
            SharedInfo.shared.address = address
            self.dustAPIService.requestObservatory()
              .subscribe(
                onNext: { response in
                  guard let observatory = response.observatory else { return }
                  SharedInfo.shared.observatory = observatory
                  NotificationCenter.default
                    .post(name: .didSuccessUpdatingAllLocationTasks, object: nil)
              },
                onError: { error in
                  NotificationCenter.default
                    .post(name: .didFailUpdatingAllLocationTasks,
                          object: nil,
                          userInfo: ["error": error])
              })
              .disposed(by: self.disposeBag)
        },
          onError: { error in
            NotificationCenter.default
              .post(name: .didFailUpdatingAllLocationTasks,
                    object: nil,
                    userInfo: ["error": error])
        })
        .disposed(by: self.disposeBag)
    }
  }
  
  var errorHandler: ((Error) -> Void)? {
    return { error in
      NotificationCenter.default
        .post(name: .didFailUpdatingAllLocationTasks,
              object: nil,
              userInfo: ["error": error])
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
