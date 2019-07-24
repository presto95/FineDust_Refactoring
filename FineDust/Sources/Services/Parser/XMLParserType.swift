//
//  XMLParserType.swift
//  FineDust
//
//  Created by Presto on 24/07/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import SWXMLHash

protocol XMLParserType: class {
  
  func decodeData<T>(_ data: Data, to type: T.Type) throws -> T where T: XMLIndexerDeserializable
}
