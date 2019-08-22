//
//  FeedbackRecommendationSectionCellModel.swift
//  FineDust
//
//  Created by Presto on 30/07/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import RxRelay
import RxSwift

protocol FeedbackRecommendationSectionCellModelInputs {
  
  func selectItem(at indexPath: IndexPath)
}

protocol FeedbackRecommendationSectionCellModelOutputs {
  
  var itemSelected: Observable<IndexPath> { get }
  
  var dataSource: Observable<[FeedbackRecommendationSectionModel]> { get }
}

final class FeedbackRecommendationSectionCellModel {
  
  private let itemSelectedRelay = PublishRelay<IndexPath>()
  
  private let dataSourceRelay = PublishRelay<[FeedbackRecommendationSectionModel]>()
}

extension FeedbackRecommendationSectionCellModel: FeedbackRecommendationSectionCellModelInputs {
  
  func selectItem(at indexPath: IndexPath) {
    itemSelectedRelay.accept(indexPath)
  }
}

extension FeedbackRecommendationSectionCellModel: FeedbackRecommendationSectionCellModelOutputs {
  
  var itemSelected: Observable<IndexPath> {
    return itemSelectedRelay.asObservable()
  }
  
  var dataSource: Observable<[FeedbackRecommendationSectionModel]> {
    return dataSourceRelay.asObservable()
  }
}
