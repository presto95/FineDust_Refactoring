//
//  FeedbackRecommendationSection.swift
//  FineDust
//
//  Created by Presto on 30/07/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import RxDataSources

struct FeedbackRecommendationItem {
  
  let imageName: String
  
  let title: String
}

struct FeedbackRecommendationSectionModel {
  
  var items: [Item]
}

extension FeedbackRecommendationSectionModel: SectionModelType {
  
  typealias Item = FeedbackRecommendationItem
  
  init(original: FeedbackRecommendationSectionModel, items: [Item]) {
    self = original
    self.items = items
  }
}

