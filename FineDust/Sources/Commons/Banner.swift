//
//  Banner.swift
//  FineDust
//
//  Created by Presto on 21/07/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import NotificationBannerSwift
import RxCocoa
import RxSwift

protocol BannerType {
  
  func show(title: String?, subtitle: String?, style: BannerStyle)
}

final class Banner: BannerType {
  
  func show(title: String?, subtitle: String? = nil, style: BannerStyle = .success) {
    let notificationBanner = NotificationBanner(title: title, subtitle: subtitle, style: style)
    notificationBanner.show()
  }
}

// MARK: - Reactive Extension

extension Reactive where Base: Banner {
  
  func show(title: String?, subtitle: String? = nil, style: BannerStyle = .success) -> Binder<Void> {
    return .init(base) { target, _ in
      target.show(title: title, subtitle: subtitle, style: style)
    }
  }
}
