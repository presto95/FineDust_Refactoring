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
  
  private var isPresented: Bool = false
  
  private var timer: Timer?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    bindViewModel()
    setUp()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    viewModel.setPresented()
    if !isPresented {
      isPresented.toggle()
      updateHealthKitInfo()
      updateAPIInfo()
    }
  }
  
  func bindViewModel() {
    rx.viewWillAppear
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] _ in
        self?.viewModel.setPresented()
      })
      .disposed(by: disposeBag)
    
    authorizationButton.rx.tap.asDriver()
      .drive(onNext: { [weak self] _ in
        self?.viewModel.tapAuthorizationButton()
      })
      .disposed(by: disposeBag)
    
    viewModel.authorizationButtonTapped.asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] _ in
        guard let self = self else { return }
        let alert = self.makeAuthorizationAlert()
        self.present(alert, animated: true, completion: nil)
      })
      .disposed(by: disposeBag)
    
    viewModel.steps
      .bind(to: infoView.rx.steps)
      .disposed(by: disposeBag)
    
    viewModel.distance
      .bind(to: infoView.rx.distance)
      .disposed(by: disposeBag)
}

// MARK: - LocationObserver

extension HomeViewController: LocationObserver {
  
  func handleIfSuccess(_ notification: Notification) {
    updateAPIInfo()
  }
  
  /// 데이터를 받아오는데 문제가 있으면 코어데이터에 마지막으로 저장된 값을 불러옴.
  func handleIfFail(_ notification: Notification) {
    if let error = notification.locationTaskError {
      coreDataService.requestLastSavedData { lastSaveData, error in
        if let data = lastSaveData {
          DispatchQueue.main.async {
            self.fineDustSpeechBalloonView.rx.value.onNext(data.todayFineDust)
            self.ultraFineDustSpeechBalloonView.rx.value.onNext(data.todayUltraFineDust)
            self.fineDustImageView.image
              = UIImage(named: IntakeGrade(intake: data.todayFineDust + data.todayUltraFineDust)
                .imageName)
            
            self.locationLabel.text = data.address
            self.gradeLabel.text = DustGrade(rawValue: data.grade)?.description
            self.fineDustLabel.text = "\(data.recentFineDust)μg"
          }
        }
      }
      errorLog(error.localizedDescription)
      Banner.show(title: error.localizedDescription)
    }
    updateHealthKitInfo()
  }
}

// MARK: - HealthKitAuthorizationObserver

extension HomeViewController: HealthKitAuthorizationObserver {
  
  func authorizationSharingAuthorized(_ notification: Notification) {
    updateHealthKitInfo()
    updateAPIInfo()
  }
}

// MARK: - Methods

extension HomeViewController {
  
  private func setUp() {
    timeLabel.text = DateFormatter.time.string(from: .init())
    flipFineDustImageView()
    fineDustSpeechBalloonBackgroundView.addSubview(fineDustSpeechBalloonView) {
      $0.edges.equalToSuperview()
    }
    ultraFineDustSpeechBalloonBackgroundView.addSubview(ultraFineDustSpeechBalloonView) {
      $0.edges.equalToSuperview()
    }
    
    
    registerHealthKitAuthorizationObserver()
    
    
    
    // InfoView들의 둥글 모서리와 shadow 추가
    infoContainerView.layer
      .applyShadow(color: .black, alpha: 0.5, x: 0, y: 4, blur: 16, spread: 0)
    infoContainerView.layer.cornerRadius = 10
    
    // 해상도 별 폰트 크기 조정.
    let size = fontSizeByScreen(size: currentWalkingCount.font.pointSize)
    currentWalkingCount.font = currentWalkingCount.font.withSize(size)
    currentDistance.font = currentDistance.font.withSize(size)
    
    authorizationButton.setTitle("정보가 표시되지 않나요?", for: [])
  }
  
  /// HealthKit의 걸음 수, 걸은 거리 값 업데이트하는 메소드.
  private func updateHealthKitInfo() {
    // 걸음 수 label에 표시
    healthKitService.requestTodayStepCount { value, error in
      if let error = error as? HealthKitError, error == .queryNotSearched {
        if self.healthKitService.isAuthorized {
          DispatchQueue.main.async {
            self.stepCountLabel.text = "0 걸음"
          }
        } else {
          error.presentToast()
        }
        return
      }
      
      if let value = value {
        self.coreDataService
          .saveLastSteps(Int(value)) { error in
            if error != nil {
              errorLog("마지막으로 요청한 걸음수가 저장되지 않음")
            } else {
              debugLog("마지막으로 요청한 걸음수가 성공적으로 저장됨")
            }
            if self.healthKitService.isAuthorized {
              DispatchQueue.main.async {
                self.stepCountLabel.text = "\(Int(value)) 걸음"
              }
            }
        }
      }
    }
    
    // 걸은 거리 label에 표시
    healthKitService.requestTodayDistance { value, error in
      if let error = error as? HealthKitError, error == .queryNotSearched {
        if self.healthKitService.isAuthorized {
          DispatchQueue.main.sync {
            self.distanceLabel.text = "0.0 km"
          }
        }
        return
      }
      if let value = value {
        self.coreDataService
          .saveLastDistance(value) { error in
            if error != nil {
              errorLog("마지막으로 요청한 걸음거리가 저장되지 않음")
            } else {
              debugLog("마지막으로 요청한 걸음거리가 성공적으로 저장됨")
            }
        }
        if self.healthKitService.isAuthorized {
          DispatchQueue.main.async {
            self.distanceLabel.text = String(format: "%.1f", value.kilometer) + " km"
          }
        }
      }
    }
  }
  
  /// 미세먼지량과 위치정보 같은 API정보들을 업데이트 하는 메소드.
  private func updateAPIInfo() {
    DispatchQueue.global(qos: .utility).async { [weak self] in
      guard let self = self else { return }
      // 위치에 관련된 Label들을 업데이트함.
      self.dustInfoService.requestRecentTimeInfo { info, error in
        if let error = error as? ServiceErrorType {
          error.presentToast()
          return
        }
        if let info = info {
          self.coreDataService
            .saveLastDustData(SharedInfo.shared.address,
                              info.fineDustGrade.rawValue,
                              info.fineDustValue) { error in
                                if error != nil {
                                  errorLog("마지막으로 요청한 미세먼지 정보가 저장되지 않음")
                                } else {
                                  debugLog("마지막으로 요청한 미세먼지 정보가 성공적으로 저장됨")
                                }
          }
          DispatchQueue.main.async {
            self.fineDustLabel.text = "\(info.fineDustValue)μg"
            self.locationLabel.text = SharedInfo.shared.address
            self.gradeLabel.text = info.fineDustGrade.description
          }
        }
      }
    }
    
    DispatchQueue.global(qos: .utility).async { [weak self] in
      guard let self = self else { return }
      self.intakeService.requestTodayIntake { fineDust, ultrafineDust, error in
        if let error = error as? ServiceErrorType {
          if (error as? HealthKitError) != nil {
            return
          }
          error.presentToast()
          return
        }
        if let fineDust = fineDust, let ultrafineDust = ultrafineDust {
          if self.healthKitService.isAuthorized {
            self.coreDataService
              .saveLastTodayIntake(fineDust,
                                   ultrafineDust) { error in
                                    if error != nil {
                                      errorLog("마지막으로 요청한 오늘의 먼지 흡입량 정보가 저장되지 않음")
                                    } else {
                                      debugLog("마지막으로 요청한 오늘의 먼지 흡입량 정보가 성공적으로 저장됨")
                                    }
            }
            // 마신 미세먼지양 Label들을 업데이트함.
            DispatchQueue.main.async {
              self.fineDustImageView.image
                = UIImage(named: IntakeGrade(intake: fineDust + ultrafineDust).imageName)
              self.fineDustSpeechBalloonView.rx.value.onNext(fineDust)
              self.ultraFineDustSpeechBalloonView.rx.value.onNext(ultrafineDust)

            }
          }
        }
      }
    }
  }
  
  
  /// 권한이 없을시 권한설정을 도와주는 AlertController.
  private func presentOpenHealthAppAlert() {
    
    if !healthKitService.isAuthorized {
      UIAlertController
        .alert(title: "건강 앱 접근 권한이 없습니다.",
               message:
          """
          걸음 수와 걸음거리를 얻기 위해 건강 앱에 대한 권한이 필요합니다.
          건강 앱 -> 데이터소스 -> 내안의먼지 -> 모든 쓰기, 읽기 권한을 허용해주세요.
          """
        )
        .action(title: "건강 APP", style: .default) { _, _ in
          self.openHealthApp()
        }
        .action(title: "취소", style: .cancel)
        .present(to: self)
    }
  }
  
  private func fontSizeByScreen(size: CGFloat) -> CGFloat {
    let value = size / 414
    return UIScreen.main.bounds.width * value
  }
}

// MARK: - Private Method

private extension HomeViewController {
  
  func makeAuthorizationAlert() -> UIAlertController {
    let isHealthKitAuthorized = healthKitService.isAuthorized
    let isLocationAuthorized = locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways
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
  
  private func flipFineDustImageView() {
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
