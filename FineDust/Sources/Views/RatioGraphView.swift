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

final class RatioGraphView: UIView {
  
  private let disposeBag = DisposeBag()
  
  fileprivate let viewModel = RatioGraphViewModel()
  
  @IBOutlet private weak var titleLabel: UILabel!
  
  @IBOutlet private weak var separatorView: UIView!
  
  private let ratioPieGraphView = UIView.instantiate(fromType: RatioPieGraphView.self)
  
  private let ratioStickGraphView = UIView.instantiate(fromType: RatioStickGraphView.self)
  
  override func awakeFromNib() {
    super.awakeFromNib()
    bindViewModel()
    addGraphViews()
  }
}

// MARK: - Private Method

private extension RatioGraphView {
  
  func bindViewModel() {
    viewModel.pieGraphViewDataSource.asDriver(onErrorJustReturn: (0, 0))
      .drive(ratioPieGraphView.rx.dataSource)
      .disposed(by: disposeBag)
    
    viewModel.stickGraphViewDataSource.asDriver(onErrorJustReturn: (0, 0))
      .drive(ratioStickGraphView.rx.dataSource)
      .disposed(by: disposeBag)
  }
  
  func addGraphViews() {
    addSubview(ratioPieGraphView) {
      $0.top.equalTo(titleLabel.snp.bottom).offset(8)
      $0.bottom.equalTo(snp.bottom)
      $0.leading.equalTo(snp.leading).offset(16)
      $0.trailing.equalTo(separatorView.snp.leading).offset(16)
    }
    addSubview(ratioStickGraphView) {
      $0.top.equalTo(ratioPieGraphView.snp.top)
      $0.leading.equalTo(separatorView.snp.trailing).offset(16)
      $0.bottom.equalTo(ratioPieGraphView.snp.bottom)
      $0.trailing.equalTo(snp.trailing).offset(16)
    }
  }
}

// MARK: - Reactive Extension

extension Reactive where Base: RatioGraphView {
  
  var intakeRatio: Binder<Double> {
    return .init(base) { target, intakeRatio in
      target.viewModel.setIntakeRatio(intakeRatio)
    }
  }
  
  var totalIntake: Binder<Int> {
    return .init(base) { target, totalIntake in
      target.viewModel.setTotalIntake(totalIntake)
    }
  }
  
  var todayIntake: Binder<Int> {
    return .init(base) { target, todayIntake in
      target.viewModel.setTodayIntake(todayIntake)
    }
  }
}
