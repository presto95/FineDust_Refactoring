//
//  RecommendCollectionViewCell.swift
//  FineDust
//
//  Created by 이재은 on 23/01/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift

final class FeedbackRecommendationCell: UICollectionViewCell {
  
  private let disposeBag = DisposeBag()

  @IBOutlet private weak var imageView: UIImageView!
  
  @IBOutlet private weak var titleLabel: UILabel!
  
  var title: String {
    return titleLabel.text ?? ""
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    contentView.layer.applyBorder(color: .clear, width: 0, radius: 5)
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    resetViews()
  }
  
  func configure(with feedbackContents: FeedbackContents) {
    imageView.image = UIImage(named: feedbackContents.imageName)?.resize(newWidth: 330)
    titleLabel.text = feedbackContents.title
  }
}

// MARK: - Private Method

private extension FeedbackRecommendationCell {
  
  func resetViews() {
    imageView.image = nil
    titleLabel.text = nil
  }
}
