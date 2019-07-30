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
  
  func setFeedbackContents(_ feedbackContents: FeedbackContents)
  
  func tapBackButton()
  
  func tapBookmarkButton()
}

protocol FeedbackDetailViewModelOutputs {
  
  var backButtonTapped: Observable<Void> { get }
  
  var bookmarkButtonTapped: Observable<Void> { get }
  
  var title: Observable<String> { get }
  
  var source: Observable<String> { get }
  
  var date: Observable<String> { get }
  
  var contents: Observable<String> { get }
  
  var imageName: Observable<String> { get }
  
  var isBookmarked: Observable<Bool> { get }
}

final class FeedbackDetailViewModel {
  
  private var bookmark: Bookmark = [:]
  
  private let backButtonTappedRelay = PublishRelay<Void>()
  
  private let bookmarkButtonTappedRelay = PublishRelay<Void>()
  
  private let feedbackContentsRelay = PublishRelay<FeedbackContents>()
  
  private let isBookmarkedRelay = BehaviorRelay<Bool>(value: false)
}

extension FeedbackDetailViewModel: FeedbackDetailViewModelInputs {
  
  func setFeedbackContents(_ feedbackContents: FeedbackContents) {
    feedbackContentsRelay.accept(feedbackContents)
    let bookmark = fetchBookmark()
    let isBookmarked = bookmark[feedbackContents.title] ?? false
    isBookmarkedRelay.accept(isBookmarked)
  }
  
  func tapBackButton() {
    backButtonTappedRelay.accept(Void())
  }
  
  func tapBookmarkButton() {
    bookmarkButtonTappedRelay.accept(Void())
    isBookmarkedRelay.accept(!isBookmarkedRelay.value)
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
  
  var contents: Observable<String> {
    return feedbackContentsRelay.asObservable()
      .map { $0.contents }
  }
  
  var imageName: Observable<String> {
    return feedbackContentsRelay.asObservable()
      .map { $0.imageName }
  }
  
  var isBookmarked: Observable<Bool> {
    return isBookmarkedRelay.asObservable()
  }
}

// MARK: - Private Method

private extension FeedbackDetailViewModel {
  
  func fetchBookmark() -> Bookmark {
    return UserDefaults.standard.dictionary(forKey: "bookmark") as? Bookmark ?? [:]
  }
  
  func saveBookmark(byTitle title: String, bookmarked: Bool) {
    var bookmark = UserDefaults.standard.dictionary(forKey: "bookmark") as? Bookmark ?? [:]
    bookmark[title] = bookmarked
    UserDefaults.standard.set(bookmark, forKey: "bookmark")
  }
}
