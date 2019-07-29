//
//  CurrentDustInfo.swift
//  FineDust
//
//  Created by Presto on 01/02/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import Foundation

struct RecentDustInfo {
  
  let dustValue: DustPair<Int>
  
  let dustGrade: DustPair<DustGrade>
  
  let updatedTime: Date
}
