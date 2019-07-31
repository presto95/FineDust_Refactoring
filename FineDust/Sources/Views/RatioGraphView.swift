//
//  RatioGraphView.swift
//  FineDust
//
//  Created by Presto on 22/01/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

final class RatioGraphView: UIView {
  
  weak var dataSource: RatioGraphViewDataSource?
  
  private let disposeBag = DisposeBag()
  
  fileprivate let viewModel = RatioGraphViewModel()
  
  @IBOutlet private weak var titleLabel: UILabel!
  
  @IBOutlet private weak var separatorView: UIView!
  
  private let pieGraphView = UIView.instantiate(fromType: RatioPieGraphView.self)
  
  private let stickGraphView = UIView.instantiate(fromType: RatioStickGraphView.self)
  
  override func awakeFromNib() {
    super.awakeFromNib()
    bindViewModel()
    setup()
  }
  
  func setup() {
    addSubview(pieGraphView) {
      $0.top.equalTo(titleLabel.snp.bottom).offset(8)
      $0.bottom.equalTo(snp.bottom)
      $0.leading.equalTo(snp.leading).offset(16)
      $0.trailing.equalTo(separatorView.snp.leading).offset(16)
    }
    addSubview(stickGraphView) {
      $0.top.equalTo(pieGraphView.snp.top)
      $0.leading.equalTo(separatorView.snp.trailing).offset(16)
      $0.bottom.equalTo(pieGraphView.snp.bottom)
      $0.trailing.equalTo(snp.trailing).offset(16)
    }
  }
}

// MARK: - Private Method

private extension RatioGraphView {
  
  func bindViewModel() {
    viewModel.pieGraphViewDataSource.asDriver(onErrorJustReturn: (0, 0))
      .drive(pieGraphView.rx.setup)
      .disposed(by: disposeBag)
    
    viewModel.stickGraphViewDataSource.asDriver(onErrorJustReturn: (0, 0))
      .drive(stickGraphView.rx.setup)
      .disposed(by: disposeBag)
  }
}

// MARK: - Reactive Extension

extension Reactive where Base: RatioGraphView {
  
  /// 전체 흡입량에 대한 부분의 비율.
  var intakeRatio: Binder<Double> {
    return .init(base) { target, intakeRatio in
      target.viewModel.setIntakeRatio(intakeRatio)
    }
  }
  
  /// 일주일간 총 흡입량.
  var totalIntake: Binder<Int> {
    return .init(base) { target, totalIntake in
      target.viewModel.setTotalIntake(totalIntake)
    }
  }
  
  /// 오늘의 흡입량.
  var todayIntake: Binder<Int> {
    return .init(base) { target, todayIntake in
      target.viewModel.setTodayIntake(todayIntake)
    }
  }
}
