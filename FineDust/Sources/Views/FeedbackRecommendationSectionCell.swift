//
//  FeedbackRecommendationSectionCell.swift
//  FineDust
//
//  Created by Presto on 30/07/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import UIKit

import RxCocoa
import RxDataSources
import RxSwift

final class FeedbackRecommendationSectionCell: UITableViewCell {
  
  typealias DataSource = RxCollectionViewSectionedReloadDataSource<FeedbackRecommendationSectionModel>
  
  private let disposeBag = DisposeBag()
  
  fileprivate let viewModel = FeedbackRecommendationSectionCellModel()
  
  private var dataSource: DataSource!
  
  @IBOutlet private weak var collectionView: UICollectionView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    dataSource = .init(configureCell: { dataSource, collectionView, indexPath, feedbackItem in
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recommendCell", for: indexPath) as? FeedbackRecommendationCell else {
        return UICollectionViewCell()
      }
      return cell
    })
    bindViewModel()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
  }
}

// MARK: - Private Method

private extension FeedbackRecommendationSectionCell {
  
  func bindViewModel() {
    viewModel.dataSource
      .bind(to: collectionView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    collectionView.rx.itemSelected.asDriver()
      .drive(onNext: { [weak self] indexPath in
        self?.collectionView.deselectItem(at: indexPath, animated: true)
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - Reactive Extension

extension Reactive where Base: FeedbackRecommendationSectionCell {
  
  var itemSelected: Observable<IndexPath> {
    return base.viewModel.itemSelected
  }
}
