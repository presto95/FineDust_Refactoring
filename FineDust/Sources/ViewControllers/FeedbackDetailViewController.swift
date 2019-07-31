//
//  FeedbackDetailViewController.swift
//  FineDust
//
//  Created by Presto on 15/02/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import UIKit

import RxCocoa
import RxOptional
import RxSwift
import RxViewController

final class FeedbackDetailViewController: UIViewController {
  
  private let disposeBag = DisposeBag()
  
  fileprivate let viewModel = FeedbackDetailViewModel()
  
  @IBOutlet private weak var backButton: UIButton!
  
  @IBOutlet private weak var bookmarkButton: UIButton!
  
  @IBOutlet private weak var imageScrollView: UIScrollView!
  
  @IBOutlet private weak var totalScrollView: UIScrollView!
  
  @IBOutlet private weak var imageView: UIImageView!
  
  @IBOutlet private weak var titleLabel: UILabel!
  
  @IBOutlet private weak var sourceLabel: UILabel!
  
  @IBOutlet private weak var dateLabel: UILabel!
  
  @IBOutlet private weak var contentsLabel: UILabel!
  
  var feedbackContents: FeedbackContents?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    bindViewModel()
    imageScrollView.delegate = self
  }
}

// MARK: - Private Method

private extension FeedbackDetailViewController {
  
  func bindViewModel() {
    rx.viewWillAppear.asDriver()
      .distinctUntilChanged()
      .map { [weak self] _ in self?.feedbackContents }
      .filterNil()
      .drive(onNext: { [weak self] feedbackContents in
        self?.viewModel.setFeedbackContents(feedbackContents)
      })
      .disposed(by: disposeBag)
    
    backButton.rx.tap.asDriver()
      .drive(onNext: { [weak self] _ in
        self?.viewModel.tapBackButton()
      })
      .disposed(by: disposeBag)
    
    bookmarkButton.rx.tap.asDriver()
      .drive(onNext: { [weak self] _ in
        self?.viewModel.tapBookmarkButton()
      })
      .disposed(by: disposeBag)
    
    viewModel.backButtonTapped.asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] _ in
        self?.navigationController?.popViewController(animated: true)
      })
      .disposed(by: disposeBag)
    
    viewModel.bookmarkButtonTapped.asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] _ in
        self?.bookmarkButton.isSelected.toggle()
      })
      .disposed(by: disposeBag)
    
    viewModel.title
      .bind(to: titleLabel.rx.text)
      .disposed(by: disposeBag)
    
    viewModel.source
      .bind(to: sourceLabel.rx.text)
      .disposed(by: disposeBag)
    
    viewModel.date
      .bind(to: dateLabel.rx.text)
      .disposed(by: disposeBag)
    
    viewModel.imageName
      .map { UIImage(named: $0) }
      .map { $0?.resize(newWidth: UIScreen.main.bounds.width) }
      .bind(to: imageView.rx.image)
      .disposed(by: disposeBag)
    
    viewModel.contents
      .bind(to: contentsLabel.rx.text)
      .disposed(by: disposeBag)
  }
}

// MARK: - Implement UIScrollViewDelegate

extension FeedbackDetailViewController: UIScrollViewDelegate {
  
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return imageView
  }
}
