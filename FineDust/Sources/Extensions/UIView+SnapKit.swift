//
//  UIView+SnapKit.swift
//  FineDust
//
//  Created by Presto on 25/07/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import UIKit

import SnapKit

extension UIView {
  
  func addSubview(_ view: UIView, constraints: (ConstraintMaker) -> Void) {
    addSubview(view)
    view.snp.makeConstraints(constraints)
  }
}
