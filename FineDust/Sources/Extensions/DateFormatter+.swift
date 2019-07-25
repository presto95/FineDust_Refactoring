//
//  DateFormatter+.swift
//  FineDust
//
//  Created by Presto on 08/02/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import Foundation

extension DateFormatter {
  
  static let dateTime = DateFormatter().then {
    $0.dateFormat = "yyyy-MM-dd HH:mm"
  }
  
  static let dateDay = DateFormatter().then {
    $0.dateStyle = .long
    $0.timeStyle = .none
  }
  
  static let date = DateFormatter().then {
    $0.dateFormat = "yyyy-MM-dd"
  }
  
  static let hour = DateFormatter().then {
    $0.dateFormat = "HH"
  }
  
  static let day = DateFormatter().then {
    $0.dateFormat = "d"
  }
  
  static let time = DateFormatter().then {
    $0.dateFormat = "a hh : mm"
  }
}
