//
//  StatisticsViewController.swift
//  FineDust
//
//  Created by Presto on 22/01/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift

final class StatisticsViewController: UIViewController {
  
  private enum Layer {
    
    static let cornerRadius: CGFloat = 8.0
    
    static let borderWidth: CGFloat = 1.0
  }
  
  private let disposeBag = DisposeBag()
  
  private let viewModel = StatisticsViewModel()
  
  @IBOutlet private weak var scrollView: UIScrollView!
  
  @IBOutlet private weak var segmentedControl: UISegmentedControl!
  
  @IBOutlet private weak var stickGraphBackgroundView: UIView!
  
  @IBOutlet private weak var ratioGraphBackgroundView: UIView!
  
  private let stickGraphView = UIView.instantiate(fromType: StickGraphView.self)
  
  private let ratioGraphView = UIView.instantiate(fromType: RatioGraphView.self)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    bindViewModel()
    scrollView.contentInset = .init(top: 8, left: 0, bottom: 16, right: 0)
    stickGraphBackgroundView.layer.applyBorder(color: Asset.graphBorder.color,
                                               width: Layer.borderWidth,
                                               radius: Layer.cornerRadius)
    ratioGraphBackgroundView.layer.applyBorder(color: Asset.graphBorder.color,
                                               width: Layer.borderWidth,
                                               radius: Layer.cornerRadius)
    stickGraphBackgroundView.addSubview(stickGraphBackgroundView) { $0.edges.equalToSuperview() }
    ratioGraphBackgroundView.addSubview(ratioGraphBackgroundView) { $0.edges.equalToSuperview() }
  }
  
  func bindViewModel() {
    rx.viewDidAppear.asDriver()
      .distinctUntilChanged()
      .drive(onNext: { [weak self] _ in
        self?.viewModel.setPresented()
      })
      .disposed(by: disposeBag)
    
    viewModel.isPresented.asDriver(onErrorJustReturn: false)
      .distinctUntilChanged()
      .drive(onNext: { [weak self] _ in
        self?.viewModel.updateData()
      })
      .disposed(by: disposeBag)

    segmentedControl.rx.selectedSegmentIndex.asDriver()
      .drive(onNext: { [weak self] index in
        self?.viewModel.selectSegmentedControl(at: index)
      })
      .disposed(by: disposeBag)
    
    viewModel.selectedSegmentedControlIndex
      .distinctUntilChanged()
      .withLatestFrom(viewModel.intakeData) { index, intakeData in
        index == 0
          ? intakeData.weekDust.map { $0.fineDust }
          : intakeData.weekDust.map { $0.ultraFineDust}
      }
      .bind(to: stickGraphView.rx.intakes)
      .disposed(by: disposeBag)
    
    viewModel.selectedSegmentedControlIndex
      .distinctUntilChanged()
      .withLatestFrom(viewModel.todayDustRatio) { index, todayDustRatio in
        index == 0
          ? todayDustRatio.fineDust
          : todayDustRatio.ultraFineDust
      }
      .bind(to: ratioGraphView.rx.intakeRatio)
      .disposed(by: disposeBag)
    
    viewModel.selectedSegmentedControlIndex
      .distinctUntilChanged()
      .withLatestFrom(viewModel.intakeData) { index, intakeData in
        index == 0
          ? intakeData.weekDust.map { $0.fineDust }.reduce(0, +)
          : intakeData.weekDust.map { $0.ultraFineDust }.reduce(0, +)
      }
      .bind(to: ratioGraphView.rx.totalIntake)
      .disposed(by: disposeBag)
    
    viewModel.selectedSegmentedControlIndex
      .distinctUntilChanged()
      .withLatestFrom(viewModel.intakeData) { index, intakeData in
        index == 0
          ? intakeData.todayDust.fineDust
          : intakeData.todayDust.ultraFineDust
      }
      .bind(to: ratioGraphView.rx.todayIntake)
      .disposed(by: disposeBag)
    
    LocationObserver.shared.didSuccess.asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] _ in
        self?.viewModel.updateData()
      })
      .disposed(by: disposeBag)
  }
}
