//
//  Date+.swift
//  FineDust
//
//  Created by Presto on 21/01/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import Foundation

extension Date {
  
  static func before(days: Int, since date: Date = Date()) -> Date {
    return Calendar.current.date(byAdding: .day, value: -days, to: date) ?? Date()
  }
  
  static func after(days: Int, since date: Date = Date()) -> Date {
    return Calendar.current.date(byAdding: .day, value: days, to: date) ?? Date()
  }
  
  func before(days: Int) -> Date {
    return Calendar.current.date(byAdding: .day, value: -days, to: self) ?? Date()
  }
  
  func after(days: Int) -> Date {
    return Calendar.current.date(byAdding: .day, value: days, to: self) ?? Date()
  }
  
  static func start(of date: Date = Date()) -> Date {
    return Calendar.current.startOfDay(for: date)
  }
  
  static func end(of date: Date = Date()) -> Date {
    let components = DateComponents(day: 1, second: -1)
    return Calendar.current.date(byAdding: components, to: start(of: date)) ?? Date()
  }
  
  var start: Date {
    return Calendar.current.startOfDay(for: self)
  }
  
  var end: Date {
    let components = DateComponents(day: 1, second: -1)
    return Calendar.current.date(byAdding: components, to: start) ?? Date()
  }
  
  var isToday: Bool {
    return Calendar.current.isDateInToday(self)
  }
  
  static func between(_ startDate: Date, _ endDate: Date) -> [Date] {
    var result = [Date]()
    var start = startDate.start
    let end = endDate.end
    while start <= end {
      result.append(start)
      start = start.after(days: 1)
    }
    return result
  }
}
