//
//  ValueGraphView.swift
//  FineDust
//
//  Created by Presto on 22/01/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift

final class StickGraphView: UIView {

  private enum Layer {
    
    static let radius: CGFloat = 2.0
    
    static let borderWidth: CGFloat = 1.0
  }
  
  private enum Animation {
    
    static let duration: TimeInterval = 1.0
    
    static let delay: TimeInterval = 0.0
    
    static let damping: CGFloat = 0.7
    
    static let springVelocity: CGFloat = 0.5
    
    static let options: UIView.AnimationOptions = .curveEaseInOut
  }
  
  private let disposeBag = DisposeBag()
  
  fileprivate let viewModel = StickGraphViewModel()
  
  @IBOutlet private weak var titleLabel: UILabel!
  
  @IBOutlet private weak var dateLabel: UILabel!
  
  @IBOutlet private var unitLabels: [UILabel]!
  
  @IBOutlet private var graphViews: [UIView]!

  @IBOutlet private var dayLabels: [UILabel]!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    bindViewModel()
    for (index, view) in graphViews.enumerated() {
      view.layer.applyBorder(radius: Layer.radius)
      view.backgroundColor = graphBackgroundColor(at: index)
    }
  }
}

// MARK: - Private Method

private extension StickGraphView {
  
  func bindViewModel() {
    viewModel.intakeRatios.asDriver(onErrorJustReturn: [])
      .do(onNext: { _ in
        for graphView in self.graphViews {
          graphView.snp.updateConstraints { $0.height.equalTo(1) }
        }
        self.layoutIfNeeded()
      })
      .drive(onNext: { ratios in
        for (index, ratio) in ratios.enumerated() {
          UIView.animate(
            withDuration: Animation.duration,
            delay: Animation.delay,
            usingSpringWithDamping: Animation.damping,
            initialSpringVelocity: Animation.springVelocity,
            options: Animation.options,
            animations: { [weak self] in
              self?.graphViews[index].snp.updateConstraints { $0.height.equalTo(ratio) }
              self?.layoutIfNeeded()
            },
            completion: nil
          )
        }
      })
      .disposed(by: disposeBag)
    
    viewModel.axisTexts
      .withLatestFrom(Observable.just(unitLabels)) { ($0, $1) }
      .asDriver(onErrorJustReturn: ([], []))
      .drive(onNext: { texts, labels in
        zip(texts, labels).forEach { $1.text = $0 }
      })
      .disposed(by: disposeBag)
    
    viewModel.dayTexts
      .withLatestFrom(Observable.just(unitLabels)) { ($0, $1) }
      .asDriver(onErrorJustReturn: ([], []))
      .drive(onNext: { texts, labels in
        zip(texts, labels).forEach { $1.text = $0 }
      })
      .disposed(by: disposeBag)
    
    viewModel.date.asDriver(onErrorJustReturn: "")
      .drive(dateLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  func graphBackgroundColor(at index: Int) -> UIColor {
    if index == 6 {
      return Asset.graphToday.color
    }
    return index.isMultiple(of: 2) ? Asset.graph1.color : Asset.graph2.color
  }
}

// MARK: - Reactive Extension

extension Reactive where Base: StickGraphView {
  
  /// 오늘의 이전 날부터 일주일간의 흡입량.
  var intakes: Binder<[Int]> {
    return .init(base) { target, intakes in
      target.viewModel.setIntakes(intakes)
    }
  }
}
