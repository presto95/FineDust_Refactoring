//
//  PersistenceService.swift
//  FineDust
//
//  Created by Presto on 22/07/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import Foundation

import RealmSwift

final class PersistenceService: PersistenceServiceType {
  
  private let realm = try! Realm()
  
  private var user: UserModel? {
    guard let object = realm.objects(UserModel.self).last else { return nil }
    return object
  }
  
  private var intakes: Results<IntakeModel> {
    return realm.objects(IntakeModel.self)
  }
  
  func lastAccessedDate() -> Date? {
    return user?.lastAccessedDate
  }
  
  func saveLastAccessedDate(_ date: Date) {
    try! realm.write {
      user?.lastAccessedDate = .init()
    }
  }
  
  func intakes(from startDate: Date, to endDate: Date) -> [Date: DustPair<Int>] {
    var dateIntakeValuePair = [Date: DustPair<Int>]()
    let dates = Date.between(startDate.start, endDate.end)
    let intakesInDates = Array(intakes.filter { (startDate...endDate).contains($0.date) })
    dates.forEach { date in
      let intakeInCurrentDate = intakesInDates.filter { $0.date.start == date }.first
      if let currentIntake = intakeInCurrentDate {
        dateIntakeValuePair[date] = .init(fineDust: Int(currentIntake.fineDust),
                                          ultraFineDust: Int(currentIntake.ultraFineDust))
      }
    }
    return dateIntakeValuePair
  }
  
  func saveIntake(_ intake: DustPair<Int>, at date: Date) {
    let object = IntakeModel().then {
      $0.fineDust = intake.fineDust
      $0.ultraFineDust = intake.ultraFineDust
      $0.date = date
    }
    try! realm.write {
      realm.add(object)
    }
  }
  
  func saveIntakes(_ intakes: [DustPair<Int>], at dates: [Date]) {
    zip(intakes, dates).forEach { intakeValue, date in
      let object = IntakeModel().then {
        $0.fineDust = intakeValue.fineDust
        $0.ultraFineDust = intakeValue.ultraFineDust
        $0.date = date
      }
      try! realm.write {
        realm.add(object)
      }
    }
  }
  
  func lastSavedData() -> LastSavedData? {
    guard let user = user else { return nil }
    let lastSavedData = LastSavedData(todayDust: user.todayDust,
                  distance: user.distance,
                  steps: user.steps,
                  address: user.address,
                  grade: user.grade,
                  recentFineDust: user.recentFineDust,
                  weekDust: user.weekDust)
    return lastSavedData
  }
  
  func saveLastSteps(_ steps: Int) {
    try! realm.write {
      user?.steps = steps
    }
  }
  
  func saveLastDistance(_ distance: Double) {
    try! realm.write {
      user?.distance = distance
    }
  }
  
  func saveLastDustData(address: String, grade: Int, recentFineDust: Int) {
    try! realm.write {
      user?.address = address
      user?.grade = grade
      user?.recentFineDust = recentFineDust
    }
  }
  
  func saveLastTodayIntake(_ intake: DustPair<Int>) {
    try! realm.write {
      user?.todayFineDust = intake.fineDust
      user?.todayUltraFineDust = intake.ultraFineDust
    }
  }
  
  func saveLastWeekIntake(_ intakes: [DustPair<Int>]) {
    let fineDusts = intakes.map { $0.fineDust }
    let ultraFineDusts = intakes.map { $0.ultraFineDust }
    try! realm.write {
      user?.weekFineDust.removeAll()
      user?.weekUltraFineDust.removeAll()
      user?.weekFineDust.append(objectsIn: fineDusts)
      user?.weekUltraFineDust.append(objectsIn: ultraFineDusts)
    }
  }
}
