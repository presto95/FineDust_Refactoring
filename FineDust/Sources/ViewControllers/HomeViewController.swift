//
//  ViewController.swift
//  FineDust
//
//  Created by Presto on 21/01/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift
import RxViewController

final class HomeViewController: UIViewController {
  
  private let disposeBag = DisposeBag()
  
  fileprivate let viewModel = HomeViewModel()
  
  @IBOutlet private weak var authorizationButton: UIButton!
  
  @IBOutlet private weak var fineDustSpeechBalloonBackgroundView: UIView!
  
  @IBOutlet private weak var ultraFineDustSpeechBalloonBackgroundView: UIView!
  
  @IBOutlet private weak var fineDustImageView: UIImageView!
  
  @IBOutlet private weak var infoContainerView: UIView!
  
  private let fineDustSpeechBalloonView
    = UIView.instantiate(fromType: IntakeSpeechBubbleView.self)
  
  private let ultraFineDustSpeechBalloonView
    = UIView.instantiate(fromType: IntakeSpeechBubbleView.self)
  
  private let infoView
    = UIView.instantiate(fromType: HomeInfoView.self)
  
  private var timer: Timer?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    bindViewModel()
    setUp()
  }
}

// MARK: - Private Method

private extension HomeViewController {
  
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
        self?.viewModel.updateDustData()
        self?.viewModel.updateHealthKitData()
      })
      .disposed(by: disposeBag)
    
    authorizationButton.rx.tap.asDriver()
      .drive(onNext: { [weak self] _ in
        self?.viewModel.tapAuthorizationButton()
      })
      .disposed(by: disposeBag)
    
    viewModel.authorizationButtonTapped.asDriver(onErrorJustReturn: (false, false))
      .map(makeAuthorizationAlert)
      .drive(rx.present)
      .disposed(by: disposeBag)
    
    viewModel.time.asDriver(onErrorJustReturn: "")
      .drive(infoView.rx.time)
      .disposed(by: disposeBag)
    
    viewModel.steps.asDriver(onErrorJustReturn: 0)
      .drive(infoView.rx.steps)
      .disposed(by: disposeBag)
    
    viewModel.distance.asDriver(onErrorJustReturn: 0)
      .drive(infoView.rx.distance)
      .disposed(by: disposeBag)
    
    viewModel.todayIntake.asDriver(onErrorJustReturn: .init(fineDust: 0, ultraFineDust: 0))
      .map { $0.fineDust }
      .drive(fineDustSpeechBalloonView.rx.value)
      .disposed(by: disposeBag)
    
    viewModel.todayIntake.asDriver(onErrorJustReturn: .init(fineDust: 0, ultraFineDust: 0))
      .map { $0.ultraFineDust }
      .drive(ultraFineDustSpeechBalloonView.rx.value)
      .disposed(by: disposeBag)
    
    viewModel.fineDustImageName.asDriver(onErrorJustReturn: "")
      .map(UIImage.init)
      .drive(fineDustImageView.rx.image)
      .disposed(by: disposeBag)
    
    LocationObserver.shared.didSuccess.asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] _ in
        self?.viewModel.updateDustData()
      })
      .disposed(by: disposeBag)
    
    LocationObserver.shared.didError.asDriver(onErrorJustReturn: NSError(domain: "",
                                                                         code: 0,
                                                                         userInfo: nil))
      .drive(onNext: { [weak self] _ in
        self?.viewModel.fetchLastSavedData()
        self?.viewModel.updateHealthKitData()
      })
      .disposed(by: disposeBag)
    
    HealthKitObserver.shared.authorized.asDriver()
      .filter { $0 }
      .drive(onNext: { [weak self] _ in
        self?.viewModel.updateDustData()
        self?.viewModel.updateHealthKitData()
      })
      .disposed(by: disposeBag)
  }
  
  func flipFineDustImageView() {
    timer?.invalidate()
    timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
      guard let identity = self?.fineDustImageView.transform.isIdentity else { return }
      if identity {
        self?.fineDustImageView.transform = .init(scaleX: -1, y: 1)
      } else {
        self?.fineDustImageView.transform = .identity
      }
    }
    timer?.fire()
  }
}

// MARK: - Methods

extension HomeViewController {
  
  private func setUp() {
    fineDustSpeechBalloonBackgroundView.addSubview(fineDustSpeechBalloonView) {
      $0.edges.equalToSuperview()
    }
    ultraFineDustSpeechBalloonBackgroundView.addSubview(ultraFineDustSpeechBalloonView) {
      $0.edges.equalToSuperview()
    }
    infoContainerView.layer
      .applyShadow(color: .black, alpha: 0.5, x: 0, y: 4, blur: 16, spread: 0)
    infoContainerView.layer.cornerRadius = 10
    flipFineDustImageView()
  }
}

// MARK: - Private Method

private extension HomeViewController {
  
  func makeAuthorizationAlert(isHealthKitAuthorized: Bool,
                              isLocationAuthorized: Bool) -> UIAlertController {
    let alert = UIAlertController(title: "정보가 표시되지 않나요?",
                                  message: "정보를 확인하려면 건강 및 위치에 대한 권한을 허용해야 합니다.",
                                  preferredStyle: .actionSheet)
    let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
    if !isHealthKitAuthorized {
      let healthKitAction = UIAlertAction(title: "건강 앱", style: .default) { [weak self] _ in
        self?.viewModel.tapHealthAppOpeningButton()
      }
      alert.addAction(healthKitAction)
    }
    if !isLocationAuthorized {
      let locationAction = UIAlertAction(title: "위치 정보", style: .default) { [weak self] _ in
        self?.viewModel.tapSettingAppOpeningButton()
      }
      alert.addAction(locationAction)
    }
    alert.addAction(cancelAction)
    return alert
  }
}
