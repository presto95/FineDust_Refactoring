//
//  Reactive+UINavigationController.swift
//  FineDust
//
//  Created by Presto on 01/08/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import RxCocoa
import RxSwift

extension Reactive where Base: UINavigationController {
  
  var push: Binder<UIViewController> {
    return .init(base) { target, viewController in
      target.pushViewController(viewController, animated: true)
    }
  }
  
  var pop: Binder<Void> {
    return .init(base) { target, _ in
      target.popViewController(animated: true)
    }
  }
}
