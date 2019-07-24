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
    
    var fineDustValue: Int {
      return Int(fineDustValueString) ?? 0
    }
    
    var fineDustGrade: Int {
      return Int(fineDustGradeString) ?? 0
    }
    
    var ultrafineDustValue: Int {
      return Int(ultraFineDustValueString) ?? 0
    }
    
    var ultrafineDustGrade: Int {
      return Int(ultraFineDustGradeString) ?? 0
    }
    
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
