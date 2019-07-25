//
//  UIView+.swift
//  FineDust
//
//  Created by Presto on 21/01/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import UIKit

extension UIView {

  static func instantiate<View>(fromType type: View.Type) -> View where View: UIView {
    return UINib(nibName: View.classNameToString, bundle: nil)
      .instantiate(withOwner: nil, options: nil).first as? View ?? View()
  }
}
