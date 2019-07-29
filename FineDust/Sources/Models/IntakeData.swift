//
//  IntakeData.swift
//  FineDust
//
//  Created by Presto on 23/02/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

struct IntakeData {
  
  var weekDust = [DustPair<Int>](repeating: .init(fineDust: 1, ultraFineDust: 1), count: 7)
  
  var todayDust = DustPair(fineDust: 1, ultraFineDust: 1)
  
  mutating func reset(to intakeData: IntakeData) {
    self = intakeData
  }
}
