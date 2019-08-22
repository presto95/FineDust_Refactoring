//
//  FeedbackListCellModel.swift
//  FineDust
//
//  Created by Presto on 21/07/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import RxRelay
import RxSwift

protocol FeedbackListCellModelInputs {
  
  func tapBookmarkButton()
  
  func setFeedbackContents(_ feedbackContents: FeedbackContents)
  
  func setIsBookmarked(_ bookmarked: Bool)
}

protocol FeedbackListCellModelOutputs {
  
  var bookmarkButtonTapped: Observable<Void> { get }
  
  var imageName: Observable<String> { get }
  
  var title: Observable<String> { get }
  
  var source: Observable<String> { get }
  
  var date: Observable<String> { get }
  
  var isbookmarked: Observable<Bool> { get }
}

final class FeedbackListCellModel {
  
  private let bookmarkRelay = BehaviorRelay<Bookmark>(value: [:])
  
  private let bookmarkButtonTappedRelay = PublishRelay<Void>()
  
  private let feedbackContentsRelay = PublishRelay<FeedbackContents>()
  
  private let isBookmarkedRelay = BehaviorRelay<Bool>(value: false)
}

extension FeedbackListCellModel: FeedbackListCellModelInputs {
  
  func tapBookmarkButton() {
    bookmarkButtonTappedRelay.accept(Void())
  }
  
  func setFeedbackContents(_ feedbackContents: FeedbackContents) {
    feedbackContentsRelay.accept(feedbackContents)
  }
  
  func setIsBookmarked(_ bookmarked: Bool) {
    isBookmarkedRelay.accept(bookmarked)
  }
}

extension FeedbackListCellModel: FeedbackListCellModelOutputs {
  
  var bookmarkButtonTapped: Observable<Void> {
    return bookmarkButtonTappedRelay.asObservable()
  }
  
  var imageName: Observable<String> {
    return feedbackContentsRelay.asObservable()
      .map { $0.imageName }
  }
  
  var title: Observable<String> {
    return feedbackContentsRelay.asObservable()
      .map { $0.title }
  }
  
  var source: Observable<String> {
    return feedbackContentsRelay.asObservable()
      .map { $0.source }
  }
  
  var date: Observable<String> {
    return feedbackContentsRelay.asObservable()
      .map { $0.date }
  }
  
  var isbookmarked: Observable<Bool> {
    return isBookmarkedRelay.asObservable()
  }
}

// MARK: - Private Method

private extension FeedbackListCellModel {
  
  func setBookmark() {
    guard let bookmark = UserDefaults.standard.dictionary(forKey: "bookmark") as? Bookmark
      else { return }
    bookmarkRelay.accept(bookmark)
  }
}
