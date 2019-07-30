//
//  Log.swift
//  FineDust
//
//  Created by Presto on 24/02/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

enum Log {
  
  static func debug(_ message: Any,
                    file: String = #file,
                    function: String = #function,
                    line: Int = #line) {
    #if DEBUG
    let fileName = file.split(separator: "/").last ?? ""
    let functionName = function.split(separator: "(").first ?? ""
    print("👻 [\(fileName)] \(functionName)(\(line)): \(message)")
    #endif
  }
  
  static func error(_ message: Any,
                    file: String = #file,
                    function: String = #function,
                    line: Int = #line) {
    let fileName = file.split(separator: "/").last ?? ""
    let functionName = function.split(separator: "(").first ?? ""
    print("❌ [\(fileName)] \(functionName)(\(line)): \(message)")
  }
}
