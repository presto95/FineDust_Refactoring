//
//  HomeInfoView.swift
//  FineDust
//
//  Created by Presto on 25/07/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift

final class HomeInfoView: UIView {
  
  private let disposeBag = DisposeBag()
  
  fileprivate let viewModel = HomeInfoViewModel()

  @IBOutlet private weak var distanceLabel: UILabel!
  
  @IBOutlet private weak var stepsLabel: UILabel!
  
  @IBOutlet private weak var timeLabel: UILabel!
  
  @IBOutlet private weak var addressLabel: UILabel!
  
  @IBOutlet private weak var dustValueLabel: UILabel!
  
  @IBOutlet private weak var dustGradeLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    bindViewModel()
  }
}

// MARK: - Private Method

private extension HomeInfoView {
  
  func bindViewModel() {
    viewModel.distance
      .map { "\($0)" }
      .bind(to: distanceLabel.rx.text)
      .disposed(by: disposeBag)
    
    viewModel.steps
      .map { "\($0)" }
      .bind(to: stepsLabel.rx.text)
      .disposed(by: disposeBag)
    
    viewModel.time
      .bind(to: timeLabel.rx.text)
      .disposed(by: disposeBag)
    
    viewModel.address
      .bind(to: addressLabel.rx.text)
      .disposed(by: disposeBag)
    
    viewModel.dustValue
      .map { "\($0)μg" }
      .bind(to: dustValueLabel.rx.text)
      .disposed(by: disposeBag)
    
    viewModel.dustGrade
      .map { $0.description }
      .bind(to: dustGradeLabel.rx.text)
      .disposed(by: disposeBag)
  }
}

// MARK: - Reactive Extension

extension Reactive where Base: HomeInfoView {
  
  var distance: Binder<Int> {
    return .init(base) { target, distance in
      target.viewModel.setDistance(distance)
    }
  }
  
  var steps: Binder<Int> {
    return .init(base) { target, steps in
      target.viewModel.setSteps(steps)
    }
  }
  
  var time: Binder<String> {
    return .init(base) { target, time in
      target.viewModel.setTime(time)
    }
  }
  
  var address: Binder<String> {
    return .init(base) { target, address in
      target.viewModel.setAddress(address)
    }
  }
  
  var dustValue: Binder<Int> {
    return .init(base) { target, dustValue in
      target.viewModel.setDustValue(dustValue)
    }
  }
  
  var dustGrade: Binder<DustGrade> {
    return .init(base) { target, dustGrade in
      target.viewModel.setDustGrade(dustGrade)
    }
  }
}
