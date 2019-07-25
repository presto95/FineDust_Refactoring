//
//  UIImage+.swift
//  FineDust
//
//  Created by 이재은 on 18/02/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import UIKit

extension UIImage {
  
  func resize(newWidth: CGFloat) -> UIImage? {
    let scale = newWidth / size.width
    let newHeight = size.height * scale
    UIGraphicsBeginImageContext(.init(width: newWidth, height: newHeight))
    draw(in: .init(x: 0, y: 0, width: newWidth, height: newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage
  }
}
