//
//  UIView+Extension.swift
//  ImagePostApp
//
//  Created by Joel Alcantara burgos on 6/3/21.
//

import Foundation
import UIKit

extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }

        set {
            layer.cornerRadius = newValue
        }
    }

    @IBInspectable
    var shouldRoundMakeRound: Bool {
        get {
            return frame.height == cornerRadius * 2
        }

        set {
            if newValue {
                layer.cornerRadius = frame.height / 2
            } else {
                layer.cornerRadius = 0
            }
        }
    }
}
