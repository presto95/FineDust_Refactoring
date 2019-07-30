//
//  FeedbackSection.swift
//  FineDust
//
//  Created by Presto on 30/07/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import RxDataSources

struct FeedbackItem {
  
  let imageName: String
  
  let title: String
  
  let source: String
  
  let date: String
  
  let isBookmarked: Bool
}

struct FeedbackSectionModel {
  
  var items: [Item]
}

extension FeedbackSectionModel: SectionModelType {
  
  typealias Item = FeedbackItem
  
  init(original: FeedbackSectionModel, items: [Item]) {
    self = original
    self.items = items
  }
}
