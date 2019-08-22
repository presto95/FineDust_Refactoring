//
//  FeedbackListViewController.swift
//  FineDust
//
//  Created by 이재은 on 23/01/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import UIKit

import RxCocoa
import RxDataSources
import RxSwift
import RxViewController

final class FeedbackViewController: UIViewController {
  
  private enum Section {
    
    static let recommendation = 0
    
    static let list = 1
  }
  
  typealias DataSoruce = RxTableViewSectionedReloadDataSource<FeedbackSectionModel>
  
  private let disposeBag = DisposeBag()
  
  fileprivate let viewModel = FeedbackViewModel()
  
  @IBOutlet private weak var tableView: UITableView!
  
  private var dataSource: DataSoruce!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    dataSource = .init(configureCell: { [weak self] dataSouce, tableView, indexPath, feedbackItem in
      guard let self = self else { return UITableViewCell() }
      let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifiers[indexPath.section], for: indexPath)
      switch indexPath.section {
      case Section.recommendation:
        let recommendationCell = cell as? FeedbackRecommendationSectionCell
        recommendationCell?.rx.itemSelected
          .withLatestFrom(self.viewModel.feedbackContents) { indexPath, feedbackContents in
            feedbackContents[indexPath.section]
          }
          .subscribe(onNext: { feedbackContents in
            self.pushDetailViewController(feedbackContents)
          })
          .disposed(by: self.disposeBag)
      case Section.list:
        let listCell = cell as? FeedbackListCell
      default:
        break
      }
      return cell
    })
    bindViewModel()
    navigationController?.interactivePopGestureRecognizer?.delegate = nil
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    loadFeedback()
  }
}

// MARK: - Private Method

private extension FeedbackViewController {
  
  func bindViewModel() {
    rx.viewWillAppear.asDriver(onErrorJustReturn: true)
      .drive(onNext: { [weak self] _ in
        self?.viewModel.setPresented()
      })
      .disposed(by: disposeBag)
    
    viewModel.settingButtonTapped.asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] _ in
        self?.presentSettingActionSheet()
      })
      .disposed(by: disposeBag)
    
    viewModel.sortRecentlyButtonTapped.asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] _ in
        self?.newDustFeedbacks = self?.feedbackListService.fetchFeedbacksByRecentDate()
        self?.tableView.reloadSections(.init(integer: 1), with: .automatic)
      })
      .disposed(by: disposeBag)
    
    viewModel.sortByTitleButtonTapped.asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] _ in
        self?.newDustFeedbacks = self?.feedbackListService.fetchFeedbacksByTitle()
        self?.tableView.reloadSections(.init(integer: 1), with: .automatic)
      })
      .disposed(by: disposeBag)
    
    viewModel.sortByBookmarkButtonTapped.asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] _ in
        self?.newDustFeedbacks = self?.feedbackListService.fetchFeedbacksByBookmark()
        self?.tableView.reloadSections(.init(integer: 1), with: .automatic)
      })
      .disposed(by: disposeBag)
    
    viewModel.dataSource
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    tableView.rx.itemSelected
      .withLatestFrom(viewModel.feedbackContents) { indexPath, feedbackContents in
        feedbackContents[indexPath.row]
      }
      .subscribe(onNext: { feedbackContents in
        self.pushDetailViewController(feedbackContents)
      })
      .disposed(by: disposeBag)
    
    tableView.rx.setDelegate(self)
      .disposed(by: disposeBag)
  }

  
  func pushDetailViewController(_ feedbackContents: FeedbackContents) {
    guard let detailViewController = storyboard?
      .instantiateViewController(withIdentifier: FeedbackDetailViewController.classNameToString)
      as? FeedbackDetailViewController else { return }
    detailViewController.feedbackContents = feedbackContents
    navigationController?.pushViewController(detailViewController, animated: true)
  }

  
  func presentSettingActionSheet() {
    UIAlertController
      .alert(title: "정렬 방법",
             message: "정렬 방법을 선택해 주세요.",
             style: .actionSheet)
      .action(title: "최신순") { [weak self] _, _ in
        self?.viewModel.tapSortRecentlyButton()
      }
      .action(title: "제목순") { [weak self] _, _ in
        self?.viewModel.tapSortByTitleButton()
      }
      .action(title: "북마크") { [weak self] _, _ in
        self?.viewModel.tapSortByBookmarkButton()
      }
      .action(title: "취소", style: .cancel)
      .present(to: self)
  }
  
  func loadFeedback() {
    isBookmarkedByTitle = feedbackListService.isBookmarkedByTitle
    tableView.reloadSections(sectionToReload, with: .none)
    calculateState()
    recommendFeedbacks = feedbackListService.fetchRecommededFeedbacks(by: currentState)
  }
  
  /// 미세먼지 섭취량으로 현재 상태를 계산함.
  func calculateState() {
    if let defaults = defaults {
      fineDustIntake = defaults.integer(forKey: "fineDustIntake")
      ultrafineDustIntake = defaults.integer(forKey: "ultrafineDustIntake")
      
      let totalIntake = fineDustIntake + ultrafineDustIntake
      currentState = IntakeGrade(intake: totalIntake)
    }
  }
}

// MARK: - Implement UITabelViewDataSource

//extension FeedbackViewController: UITableViewDataSource {
//
//  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//    guard let cell = tableView
//      .dequeueReusableCell(withIdentifier: reuseIdentifiers[indexPath.section], for: indexPath)
//      as? FeedbackListCell else { return UITableViewCell() }
//    if let newDustFeedbacks = newDustFeedbacks {
//      cell.configure(with: newDustFeedbacks[indexPath.row])
//    } else {
//      let feedback = feedbackListService.fetchFeedbacksByBookmark()
//      cell.configure(with: feedback[indexPath.row])
//    }
//    cell.setBookmarkButtonState(isBookmarkedByTitle: isBookmarkedByTitle)
//    return cell
//  }
//}

// MARK: - Implement UITableViewDelegate

extension FeedbackViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = UIView(frame: .init(x: 0, y: 0, width: view.bounds.width, height: 60)).then {
      $0.backgroundColor = .init(white: 1, alpha: 0.7)
    }
    let headerLabel = UILabel().then {
      $0.textColor = .darkGray
      $0.font = .systemFont(ofSize: $0.font.pointSize, weight: .bold)
    }
    headerView.addSubview(headerLabel) {
      $0.leading.equalTo(headerView.snp.leading).offset(20)
      $0.centerY.equalTo(headerView.snp.centerY)
    }
    
    // 정렬 액션시트 버튼 설정
    let button = UIButton(type: .system).then {
      $0.imageEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
      $0.setImage(Asset.sort.image, for: [])
      $0.rx.tap.asDriver()
        .drive(onNext: { [weak self] _ in
          self?.viewModel.tapSettingButton()
        })
        .disposed(by: disposeBag)
    }
    headerView.addSubview(button) {
      $0.centerY.equalTo(headerView.snp.centerY)
      $0.leading.equalTo(headerLabel.snp.trailing).offset(5)
      $0.width.equalTo(44)
      $0.height.equalTo(44)
    }
    button.isHidden = section != 1
    headerLabel.text = section == 1 ? "전체 목록" : "맞춤 정보 추천"
    return headerView
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return indexPath.section == 0 ? 330 : UITableView.automaticDimension
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 40
  }
}


// MARK: - FeedbackListCellDelegate

extension FeedbackViewController: FeedbackListCellDelegate {
  
  func feedbackListCell(_ feedbackListCell: FeedbackListCell,
                        didTapBookmarkButton button: UIButton) {
    button.isSelected.toggle()
    let title = feedbackListCell.title
    if button.isSelected {
      isBookmarkedByTitle[title] = true
      feedbackListService.saveBookmark(by: title)
    } else {
      isBookmarkedByTitle[title] = false
      feedbackListService.deleteBookmark(by: title)
    }
    self.newDustFeedbacks = self.feedbackListService.fetchFeedbacksByBookmark()
    self.tableView.reloadSections(sectionToReload, with: .none)
  }
}
