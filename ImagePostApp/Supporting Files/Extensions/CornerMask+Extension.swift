//
//  CornerMask+Extension.swift
//  ImagePostApp
//
//  Created by Joel Alcantara on 1/8/22.
//

import UIKit

extension CACornerMask {
    static var allCorners: CACornerMask = [
        .layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner
    ]
}
