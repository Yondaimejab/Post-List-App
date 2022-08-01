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
    
    var originInLastSuperView: CGPoint {
        var x = frame.origin.x
        var y = frame.origin.y
        var newSuperView = self.superview
        while newSuperView != nil {
            x += newSuperView?.frame.origin.x ?? 0.0
            y += newSuperView?.frame.origin.y ?? 0.0
            newSuperView = newSuperView?.superview
        }
        return CGPoint(x: x, y: y)
    }
}

extension UIImage {
    static var placeholder = UIImage(named: "image_placeholder")
}
