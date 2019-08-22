//
//  Result+.swift
//  FineDust
//
//  Created by Presto on 21/08/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

extension Result {
  
  var success: Success? {
    switch self {
    case let .success(success):
      return success
    case .failure:
      return nil
    }
  }
  
  var failure: Failure? {
    switch self {
    case .success:
      return nil
    case let .failure(error):
      return error
    }
  }
}
