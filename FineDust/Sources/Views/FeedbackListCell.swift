//
//  FeedbackListTableViewCell.swift
//  FineDust
//
//  Created by 이재은 on 23/01/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift

final class FeedbackListCell: UITableViewCell {
  
  private let disposeBag = DisposeBag()
  
  fileprivate let viewModel = FeedbackListCellModel()
  
  @IBOutlet private weak var feedbackImageView: UIImageView!
  
  @IBOutlet private weak var titleLabel: UILabel!
  
  @IBOutlet private weak var sourceLabel: UILabel!
  
  @IBOutlet private weak var dateLabel: UILabel!
  
  @IBOutlet private weak var bookmarkButton: UIButton!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    bindViewModel()
    feedbackImageView.layer.applyBorder(color: .clear,
                                        width: 0,
                                        radius: feedbackImageView.bounds.height / 2)
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    resetViews()
  }
  
  func configure(with feedbackContents: FeedbackContents) {
    viewModel.setFeedbackContents(feedbackContents)
  }
  
  func setBookmarkButtonState(_ isBookmarked: Bool) {
    viewModel.setIsBookmarked(isBookmarked)
  }
}

// MARK: - Private Method

private extension FeedbackListCell {
  
  func bindViewModel() {
    bookmarkButton.rx.tap.asDriver()
      .drive(onNext: { [weak self] _ in
        self?.viewModel.tapBookmarkButton()
      })
      .disposed(by: disposeBag)
    
    viewModel.imageName.asDriver(onErrorJustReturn: "")
      .map(UIImage.init)
      .map { $0?.resize(newWidth: 150) }
      .drive(feedbackImageView.rx.image)
      .disposed(by: disposeBag)
    
    viewModel.title.asDriver(onErrorJustReturn: "")
      .drive(titleLabel.rx.text)
      .disposed(by: disposeBag)
    
    viewModel.source.asDriver(onErrorJustReturn: "")
      .drive(sourceLabel.rx.text)
      .disposed(by: disposeBag)
    
    viewModel.date.asDriver(onErrorJustReturn: "")
      .drive(dateLabel.rx.text)
      .disposed(by: disposeBag)
    
    viewModel.isbookmarked.asDriver(onErrorJustReturn: false)
      .map { $0 ? Asset.yellowStar.image : Asset.starOutline.image }
      .drive(bookmarkButton.rx.image())
      .disposed(by: disposeBag)
    
    viewModel.isbookmarked.asDriver(onErrorJustReturn: false)
      .drive(bookmarkButton.rx.isSelected)
      .disposed(by: disposeBag)
  }
  
  func resetViews() {
    feedbackImageView.image = nil
    titleLabel.text = nil
    sourceLabel.text = nil
    bookmarkButton.isSelected = false
  }
}

// MARK: - Reactive Extension

extension Reactive where Base: FeedbackListCell {
  
  var bookmarkButtonTapped: ControlEvent<Void> {
    return .init(events: base.viewModel.bookmarkButtonTapped)
  }
}
