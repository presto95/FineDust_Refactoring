//
//  RatioStickGraphView.swift
//  FineDust
//
//  Created by Presto on 20/02/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

final class RatioStickGraphView: UIView {
  
  private enum Layer {
    
    static let radius: CGFloat = 2.0
  }
  
  private enum Animation {
    
    static let duration: TimeInterval = 1.0
    
    static let delay: TimeInterval = 0.0
    
    static let damping: CGFloat = 0.7
    
    static let springVelocity: CGFloat = 0.5
    
    static let options: UIView.AnimationOptions = .curveEaseInOut
  }
  
  private let disposeBag = DisposeBag()
  
  fileprivate let viewModel = RatioStickGraphViewModel()
  
  @IBOutlet private weak var percentLabel: UILabel!
  
  @IBOutlet private weak var averageIntakeLabel: UILabel!
  
  @IBOutlet private weak var todayIntakeLabel: UILabel!
  
  @IBOutlet private weak var averageIntakeGraphView: UIView!
    
  @IBOutlet private weak var todayIntakeGraphView: UIView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    bindViewModel()
    averageIntakeGraphView.layer.applyBorder(radius: Layer.radius)
    todayIntakeGraphView.layer.applyBorder(radius: Layer.radius)
  }
  
  func setup(averageIntake: Int, todayIntake: Int) {
    viewModel.setIntakeValues(averageIntake, todayIntake)
  }
}

// MARK: - Private Method

private extension RatioStickGraphView {
  
  func bindViewModel() {
    viewModel.dataSource.asDriver(onErrorJustReturn: (0, 0))
      .do(onNext: { [weak self] _ in
        // deinitializeSubviews
        self?.averageIntakeGraphView.snp.updateConstraints { $0.height.equalTo(0.01) }
        self?.todayIntakeGraphView.snp.updateConstraints { $0.height.equalTo(0.01) }
        self?.layoutIfNeeded()
      })
      .drive(onNext: { [weak self] averageIntake, todayIntake in
        guard let self = self else { return }
        // drawGraph
        let averageIntakeTempMultiplier = averageIntake >= todayIntake
          ? 1
          : CGFloat(averageIntake) / CGFloat(todayIntake)
        let todayIntakeTempMultiplier = averageIntake >= todayIntake
          ? CGFloat(todayIntake) / CGFloat(averageIntake)
          : 1
        let averageIntakeMultiplier = !averageIntakeTempMultiplier.canBecomeMultiplier
          ? 0.01
          : averageIntakeTempMultiplier
        let todayIntakeMultiplier = !todayIntakeTempMultiplier.canBecomeMultiplier
          ? 0.01
          : todayIntakeTempMultiplier
        
        UIView.animate(
          withDuration: Animation.duration,
          delay: Animation.delay,
          usingSpringWithDamping: Animation.damping,
          initialSpringVelocity: Animation.springVelocity,
          options: Animation.options,
          animations: { [weak self] in
            self?.averageIntakeGraphView.snp
              .updateConstraints { $0.height.equalTo(averageIntakeMultiplier) }
            self?.todayIntakeGraphView.snp
              .updateConstraints { $0.height.equalTo(todayIntakeMultiplier) }
            self?.layoutIfNeeded()
          },
          completion: nil
        )
      })
      .disposed(by: disposeBag)
    
    viewModel.dataSource.asDriver(onErrorJustReturn: (0, 0))
      .map { Double($0.todayIntake) / Double($0.averageIntake) * 100 }
      .map { !$0.canBecomeMultiplier ? 0 : $0 }
      .map { "\(Int($0))" }
      .drive(percentLabel.rx.text)
      .disposed(by: disposeBag)
    
    viewModel.dataSource.asDriver(onErrorJustReturn: (0, 0))
      .map { "\($0.averageIntake)" }
      .drive(averageIntakeLabel.rx.text)
      .disposed(by: disposeBag)
    
    viewModel.dataSource.asDriver(onErrorJustReturn: (0, 0))
      .map { "\($0.todayIntake)" }
      .drive(todayIntakeLabel.rx.text)
      .disposed(by: disposeBag)
  }
}

// MARK: - Reactive Extension

extension Reactive where Base: RatioStickGraphView {
  
  var dataSource: Binder<(averageIntake: Int, todayIntake: Int)> {
    return .init(base) { target, values in
      target.viewModel.setIntakeValues(values.averageIntake, values.todayIntake)
    }
  }
}
