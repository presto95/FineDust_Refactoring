//
//  ObservatoryResponseXML.swift
//  FineDust
//
//  Created by Presto on 29/01/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import SWXMLHash

struct DustAPIObservatoryResponse: DustAPIResponseType {

  struct Item: XMLIndexerDeserializable {
    
    let address: String
    
    let observatory: String
    
    let distance: Double
    
    static func deserialize(_ node: XMLIndexer) throws -> Item {
      return try .init(address: node["addr"].value(),
                       observatory: node["stationName"].value(),
                       distance: node["tm"].value())
    }
  }
  
  let result: DustAPIResponseMetadata
  
  let totalCount: Int
  
  let items: [Item]
  
  static func deserialize(_ node: XMLIndexer) throws -> DustAPIObservatoryResponse {
    let responseNode = node["response"]
    let bodyNode = responseNode["body"]
    return try .init(result: responseNode["header"].value(),
                     totalCount: bodyNode["totalCount"].value(),
                     items: bodyNode["items"]["item"].value())
  }
  
  var observatory: String? {
    return items.first?.observatory
  }
}
