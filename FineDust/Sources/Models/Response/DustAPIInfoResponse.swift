//
//  FineDustResponse.swift
//  FineDust
//
//  Created by Presto on 23/01/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import SWXMLHash

struct DustAPIInfoResponse: DustAPIResponseType {

  struct Item: XMLIndexerDeserializable {
    
    let dataTime: String
    
    let fineDustValueString: String
    
    let fineDustGradeString: String
    
    let ultraFineDustValueString: String
    
    let ultraFineDustGradeString: String
    
    static func deserialize(_ node: XMLIndexer) throws -> Item {
      return try .init(dataTime: node["dataTime"].value(),
                       fineDustValueString: node["pm10Value"].value(),
                       fineDustGradeString: node["pm10Grade"].value(),
                       ultraFineDustValueString: node["pm25Value"].value(),
                       ultraFineDustGradeString: node["pm25Grade"].value())
    }
  }
  
  let result: DustAPIResponseMetadata
  
  let totalCount: Int
  
  let items: [Item]
  
  static func deserialize(_ node: XMLIndexer) throws -> DustAPIInfoResponse {
    let responseNode = node["response"]
    let bodyNode = responseNode["body"]
    return try .init(result: responseNode["header"].value(),
                     totalCount: bodyNode["totalCount"].value(),
                     items: bodyNode["items"]["item"].value())
  }
}

extension DustAPIInfoResponse.Item {
  
  var fineDustValue: Int {
    return Int(fineDustValueString) ?? 0
  }
  
  var fineDustGrade: Int {
    return Int(fineDustGradeString) ?? 0
  }
  
  var ultraFineDustValue: Int {
    return Int(ultraFineDustValueString) ?? 0
  }
  
  var ultraFineDustGrade: Int {
    return Int(ultraFineDustGradeString) ?? 0
  }
  
  var dustValue: DustPair<Int> {
    return .init(fineDust: fineDustValue, ultraFineDust: ultraFineDustValue)
  }
  
  var dustGrade: DustPair<DustGrade> {
    return .init(fineDust: DustGrade(rawValue: fineDustGrade) ?? .default,
                 ultraFineDust: DustGrade(rawValue: ultraFineDustGrade) ?? .default)
  }
}
