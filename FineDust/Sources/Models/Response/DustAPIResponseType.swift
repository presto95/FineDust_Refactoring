//
//  DustAPIResponseType.swift
//  FineDust
//
//  Created by Presto on 24/07/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import SWXMLHash

protocol DustAPIResponseType: XMLIndexerDeserializable {
  
  associatedtype Result: XMLIndexerDeserializable
  
  associatedtype Item: XMLIndexerDeserializable
  
  var result: Result { get }
  
  var items: [Item] { get }
  
  var totalCount: Int { get }
}
