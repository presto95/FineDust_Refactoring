//
//  CALayer+.swift
//  FineDust
//
//  Created by Presto on 22/01/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import UIKit

extension CALayer {
  
  func applyBorder(color borderColor: UIColor = .black,
                   width borderWidth: CGFloat = 0,
                   radius cornerRadius: CGFloat = 0) {
    masksToBounds = true
    self.borderColor = borderColor.cgColor
    self.borderWidth = borderWidth
    self.cornerRadius = cornerRadius
  }
  
  func applyShadow(color: UIColor,
                   alpha: Float,
                   x: CGFloat,
                   y: CGFloat,
                   blur: CGFloat,
                   spread: CGFloat) {
    shadowColor = color.cgColor
    shadowOpacity = alpha
    shadowOffset = CGSize(width: x, height: y)
    shadowRadius = blur / 2.0
    if spread == 0 {
      shadowPath = nil
    } else {
      let offset = -spread
      let rect = bounds.insetBy(dx: offset, dy: offset)
      shadowPath = UIBezierPath(rect: rect).cgPath
    }
  }
  
  func applyGradient(colors: [Any],
                     locations: [NSNumber],
                     startPoint: CGPoint = .init(x: 0.5, y: 0),
                     endPoint: CGPoint = .init(x: 0.5, y: 1)) {
    let gradient = CAGradientLayer().then {
      $0.frame = bounds
      $0.startPoint = startPoint
      $0.endPoint = endPoint
      $0.colors = colors
      $0.locations = locations
    }
    mask = gradient
  }
}
