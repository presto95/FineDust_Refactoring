//
//  FeedbackViewModel.swift
//  FineDust
//
//  Created by Presto on 21/07/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import RxRelay
import RxSwift

protocol FeedbackViewModelInputs {
  
  func setPresented
  
  func tapSettingButton()
  
  func tapSortRecentlyButton()
  
  func tapSortByTitleButton()
  
  func tapSortByBookmarkButton()
}

protocol FeedbackViewModelOutputs {
  
  var settingButtonTapped: Observable<Void> { get }
  
  var sortRecentlyButtonTapped: Observable<Void> { get }
  
  var sortByTitleButtonTapped: Observable<Void> { get }
  
  var sortByBookmarkButtonTapped: Observable<Void> { get }
  
  var feedbackContents: Observable<[FeedbackContents]> { get }
  
  var dataSource: Observable<[FeedbackSectionModel]> { get }
}

final class FeedbackViewModel {
  
  enum SortingType {
    
    case recently
    
    case title
    
    case bookmark
  }
  
  var bookmark: Bookmark {
    get {
      return UserDefaults.standard.dictionary(forKey: "bookmark") as? [String: Bool] ?? [:]
    }
    set {
      UserDefaults.standard.set(newValue, forKey: "bookmark")
    }
  }
  
  private var feedbackContentsState: [FeedbackContents] = []
  
  private var numberOfFeedbackContents: Int {
    return feedbackContentsState.count
  }
  
  private let settingButtonTappedRelay = PublishRelay<Void>()
  
  private let sortRecentlyButtonTappedRelay = PublishRelay<Void>()
  
  private let sortByTitleButtonTappedRelay = PublishRelay<Void>()
  
  private let sortByBookmarkButtonTappedRelay = PublishRelay<Void>()

  private let feedbackContentsRelay = PublishRelay<[FeedbackContents]>()
}

extension FeedbackViewModel: FeedbackViewModelInputs {
  
  func setPresented() {
    isPresentedRelay.accept(Void())
  }
  
  func tapSettingButton() {
    settingButtonTappedRelay.accept(Void())
  }
  
  func tapSortRecentlyButton() {
    sortRecentlyButtonTappedRelay.accept(Void())
  }
  
  func tapSortByTitleButton() {
    sortByTitleButtonTappedRelay.accept(Void())
  }
  
  func tapSortByBookmarkButton() {
    sortByBookmarkButtonTappedRelay.accept(Void())
  }
}

extension FeedbackViewModel: FeedbackViewModelOutputs {
  
  var settingButtonTapped: Observable<Void> {
    return settingButtonTappedRelay.asObservable()
  }
  
  var sortRecentlyButtonTapped: Observable<Void> {
    return sortRecentlyButtonTappedRelay.asObservable()
  }
  
  var sortByTitleButtonTapped: Observable<Void> {
    return sortByTitleButtonTappedRelay.asObservable()
  }
  
  var sortByBookmarkButtonTapped: Observable<Void> {
    return sortByBookmarkButtonTappedRelay.asObservable()
  }
  
  var feedbackContents: Observable<[FeedbackContents]> {
    return feedbackContentsRelay.asObservable()
  }
  
  var dataSource: Observable<[FeedbackSectionModel]> {
    return .empty()
  }
}

// MARK: - Private Method

private extension FeedbackViewModel {
  
  func fetchFeedbackContents() {
    let jsonDecoder = JSONDecoder()
    guard let path = Bundle.main.path(forResource: "FeedbackContents", ofType: "json"),
      let optionalData = try? String(contentsOfFile: path).data(using: .utf8),
      let data = optionalData,
      let jsonObject = try? jsonDecoder.decode([FeedbackContents].self, from: data)
      else { return }
    feedbackContentsState = jsonObject
    feedbackContentsRelay.accept(jsonObject)
  }
  
  func fetchFeedbackContents(sortingBy sortingType: SortingType) {
    if feedbackContentsState.isEmpty {
      fetchFeedbackContents()
    }
    switch sortingType {
    case .recently:
      feedbackContentsState.sort { $0.date > $1.date }
      feedbackContentsRelay.accept(feedbackContentsState)
    case .title:
      feedbackContentsState.sort { $0.title < $1.title }
      feedbackContentsRelay.accept(feedbackContentsState)
    case .bookmark:
      var bookmarkedFeedbacks = [FeedbackContents]()
      var notBookmarkedFeedbacks = [FeedbackContents]()
      for feedback in feedbackContentsState {
        if bookmark[feedback.title] ?? false {
          bookmarkedFeedbacks.append(feedback)
        } else {
          notBookmarkedFeedbacks.append(feedback)
        }
      }
      bookmarkedFeedbacks.append(contentsOf: notBookmarkedFeedbacks)
      feedbackContentsState = bookmarkedFeedbacks
      feedbackContentsRelay.accept(bookmarkedFeedbacks)
    }
  }
  
  func feedbackContents(byTitle title: String) -> FeedbackContents? {
    return feedbackContentsState.filter { $0.title == title }.first
  }
  
  func feedbackContents(byImportance importance: FeedbackImportance) -> [FeedbackContents] {
    return feedbackContentsState
      .filter { $0.importance == importance.rawValue }
      .shuffled()
  }
  
  func recommendedFeedbackContents(byGrade grade: IntakeGrade) -> [FeedbackContents] {
    let recommendCount: [FeedbackImportance: Int] = {
      switch grade {
      case .veryGood:
        return [.important: 2, .normal: 1]
      case .good:
        return [.important: 3]
      case .normal:
        return [.veryImportant: 1, .important: 2]
      case .bad:
        return [.veryImportant: 2, .important: 1]
      case .veryBad:
        return [.veryImportant: 3]
      case .default:
        return [.important: 2, .normal: 1]
      }
    }()
    var recommendedFeedbacks = [FeedbackContents]()
    for (importance, count) in recommendCount {
      let contents = feedbackContents(byImportance: importance)
      recommendedFeedbacks.append(contentsOf: contents[0..<count])
    }
    return recommendedFeedbacks
  }
  
  func saveBookmark(bytitle title: String) {
    bookmark[title] = true
  }
  
  func deleteBookmark(byTitle title: String) {
    bookmark[title] = false
  }
}
