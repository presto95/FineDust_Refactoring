//
//  Reactive+UIViewController.swift
//  FineDust
//
//  Created by Presto on 01/08/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import RxCocoa
import RxSwift

extension Reactive where Base: UIViewController {
  
  var present: Binder<UIViewController> {
    return .init(base) { target, viewController in
      target.present(viewController, animated: true, completion: nil)
    }
  }
  
  var dismiss: Binder<Void> {
    return .init(base) { target, _ in
      target.dismiss(animated: true, completion: nil)
    }
  }
}
