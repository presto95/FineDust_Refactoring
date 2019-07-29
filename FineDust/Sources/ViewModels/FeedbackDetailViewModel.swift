//
//  FeedbackDetailViewModel.swift
//  FineDust
//
//  Created by Presto on 21/07/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import RxRelay
import RxSwift

protocol FeedbackDetailViewModelInputs {
  
  func setTitle(_ title: String)
  
  func tapBackButton()
  
  func tapBookmarkButton(selected: Bool)
}

protocol FeedbackDetailViewModelOutputs {
  
  var backButtonTapped: Observable<Void> { get }
  
  var bookmarkButtonTapped: Observable<Void> { get }
  
  var title: Observable<String> { get }
  
  var source: Observable<String> { get }
  
  var date: Observable<String> { get }
  
  var contents: Observable<String> { get }
  
  var imageName: Observable<String> { get }
}

final class FeedbackDetailViewModel {
  
  private var bookmark: Bookmark = [:]
  
  private let titleRelay = PublishRelay<String>()
  
  private let backButtonTappedRelay = PublishRelay<Void>()
  
  private let bookmarkButtonTappedRelay = PublishRelay<Void>()
  
  private let feedbackContentsRelay = PublishRelay<FeedbackContents>()
}

extension FeedbackDetailViewModel: FeedbackDetailViewModelInputs {
  
  func setTitle(_ title: String) {
    titleRelay.accept(title)
  }
  
  func tapBackButton() {
    backButtonTappedRelay.accept(Void())
  }
  
  func tapBookmarkButton(selected: Bool) {
    bookmarkButtonTappedRelay.accept(Void())
  }
}

extension FeedbackDetailViewModel: FeedbackDetailViewModelOutputs {
  
  var backButtonTapped: Observable<Void> {
    return backButtonTappedRelay.asObservable()
  }
  
  var bookmarkButtonTapped: Observable<Void> {
    return bookmarkButtonTappedRelay.asObservable()
  }
  
  var title: Observable<String> {
    
  }
  
  var source: Observable<String> {
    
  }
  
  var date: Observable<String> {
    
  }
  
  var contents: Observable<String> {
    
  }
  
  var imageName: Observable<String> {
    
  }
}

// MARK: - Private Method

private extension feedbackdetailviewm {
  
  func fetchFeedbackContents(byTitle title: String) {
    
  }
}
