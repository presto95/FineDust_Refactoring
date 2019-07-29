//
//  AppDelegate.swift
//  FineDust
//
//  Created by Presto on 21/01/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import CoreLocation
import UIKit

import Then

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  private let healthKitService = HealthKitService()
  
  private let persistenceService = PersistenceService()
  
  private let locationManager = LocationManager()
  
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
    
    return true
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    locationManager.startUpdatingLocation()
    HealthKitObserver.shared.authorized.accept(healthKitService.isAuthorized)
  }
}
