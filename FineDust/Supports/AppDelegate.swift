//
//  AppDelegate.swift
//  FineDust
//
//  Created by Presto on 21/01/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import UIKit

import RxSwift
import Then

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  private let disposeBag = DisposeBag()
  
  private let healthKitService = HealthKitService()
  
  private let persistenceService = PersistenceService()
  
  private let geocodeService = GeocodeService()
  
  private let dustAPIService = DustAPIService()
  
  private let locationManager = LocationManager.shared
  
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
    window?.tintColor = Asset.graph2.color
    
    UINavigationBar.appearance().do {
      $0.tintColor = .white
      $0.barTintColor = .white
      $0.titleTextAttributes = [.foregroundColor: UIColor.black]
    }
    UITabBar.appearance().do {
      $0.unselectedItemTintColor = .lightGray
      $0.barTintColor = .white
    }
    
    if persistenceService.lastAccessedDate() == nil {
      persistenceService.saveLastAccessedDate(.init())
    }
    healthKitService.requestAuthorization()
    
    locationManager.requestAuthorization()
    bindLocationManager()
    
    return true
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    locationManager.startUpdatingLocation()
    HealthKitObserver.shared.authorized.accept(healthKitService.isAuthorized)
  }
}

// MARK: - Private Method

private extension AppDelegate {
  
  func bindLocationManager() {
    locationManager.rx.authorizationStatus
      .subscribe(onNext: { status in
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
          self.locationManager.startUpdatingLocation()
        default:
          LocationObserver.shared.didAuthorizationDenied.accept(Void())
        }
      })
      .disposed(by: disposeBag)
    
    locationManager.rx.location
      .subscribe(onNext: { location in
        self.locationManager.stopUpdatingLocation()
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
      })
      .disposed(by: disposeBag)
    
    locationManager.rx.error
      .subscribe(onNext: { error in
        LocationObserver.shared.didError.accept(error)
      })
      .disposed(by: disposeBag)
  }
}
