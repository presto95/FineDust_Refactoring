//
//  RatioPieGraphView.swift
//  FineDust
//
//  Created by Presto on 20/02/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift

final class RatioPieGraphView: UIView {
  
  private enum Layer {
    
    static let lineWidth: CGFloat = 10.0
  }
  
  private let disposeBag = DisposeBag()
  
  fileprivate let viewModel = RatioPieGraphViewModel()
  
  @IBOutlet private weak var percentLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    bindViewModel()
  }
  
  func setup(ratio: Double, endAngle: Double) {
    viewModel.setValues(ratio: ratio, endAngle: endAngle)
  }
}

// MARK: - Private Method

private extension RatioPieGraphView {
  
  func bindViewModel() {
    let valuesUpdatedDrivder = viewModel.valuesUpdated.asDriver(onErrorJustReturn: (0, 0))
    
    valuesUpdatedDrivder
      .map { "\($0.ratio * 100)" }
      .drive(percentLabel.rx.text)
      .disposed(by: disposeBag)
    
    valuesUpdatedDrivder
      .drive(onNext: { [weak self] ratio, endAngle in
        guard let self = self else { return }
        // deinitializeSubviews
        self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        // drawGraph
        self.addCircleLayers(ratio: ratio)
        // setLabels
        self.addSubview(self.percentLabel) { $0.center.equalTo(self.snp.center) }
      })
      .disposed(by: disposeBag)
  }
  
  func addCircleLayers(ratio: Double) {
    layer.addSublayer(makeEntireShapeLayer())
    layer.addSublayer(makePortionShapeLayer(ratio: ratio))
  }
  
  func makeEntireShapeLayer() -> CAShapeLayer {
    let shapeLayer = makeCircleLayer(fillColor: .clear,
                                     strokeColor: Asset.graph1.color)
    return shapeLayer
  }
  
  func makePortionShapeLayer(ratio: Double) -> CAShapeLayer {
    let shapeLayer = makeCircleLayer(fillColor: .clear,
                                     strokeColor: Asset.graphToday.color,
                                     strokeEnd: CGFloat(ratio),
                                     ratio: CGFloat(ratio))
    let animation = CABasicAnimation(keyPath: "strokeEnd").then {
      $0.fromValue = 0
      $0.toValue = CGFloat(ratio)
      $0.duration = 1
    }
    shapeLayer.add(animation, forKey: nil)
    return shapeLayer
  }
  
  func makeCircleLayer(fillColor: UIColor,
                       strokeColor: UIColor,
                       strokeEnd: CGFloat = 1,
                       ratio: CGFloat = 1) -> CAShapeLayer {
    let graphViewHeight = bounds.width * 0.8
    let path = UIBezierPath(arcCenter: .init(x: bounds.width / 2,
                                             y: bounds.height / 2),
                            radius: graphViewHeight / 2,
                            startAngle: -.pi / 2,
                            endAngle: .pi * 3 / 2,
                            clockwise: true)
    let shapeLayer = CAShapeLayer().then {
      $0.lineWidth = Layer.lineWidth
      $0.fillColor = fillColor.cgColor
      $0.strokeColor = strokeColor.cgColor
      $0.strokeEnd = ratio
      $0.path = path.cgPath
    }
    return shapeLayer
  }
}

// MARK: - Reactive Extension

extension Reactive where Base: RatioPieGraphView {
  
  var setup: Binder<(ratio: Double, endAngle: Double)> {
    return .init(base) { target, values in
      target.viewModel.setValues(ratio: values.ratio, endAngle: values.endAngle)
    }
  }
}
