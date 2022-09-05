//
//  LaunchViewController.swift
//  ImagePostApp
//
//  Created by Joel Alcantara burgos on 6/3/21.
//

import UIKit
import Lottie
import Anchorage

class LaunchViewController: UIViewController {

    // Constants
    enum Constants {
        static let startAnimationTime: Double = 3
        static let homeSegue = "homeSegueIdentifier"
    }

    // Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lottieAnimationView: AnimationView!
    
     var viewStartFrame : CGRect = {
        return CGRect(
            x: 250.0,
            y: 100.0,
            width: 185.0,
            height: 185.0
        )
    }()
    lazy var viewFinalFrame: CGRect = {
        return CGRect(
            x: self.view.frame.width / 4,
            y: 225.0,
            width: 185.0,
            height: 185.0
        )
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    private func setupViews() {
        self.titleLabel.frame = CGRect(
            x: 20,
            y: 800.0,
            width: self.view.frame.width - 40,
            height: 50.0
        )
        guard let animation = Animation.named("111266-charecter-3", bundle: .main) else {
            return
        }
        lottieAnimationView.animation = animation
        lottieAnimationView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(reloadAnimation))
        )
        lottieAnimationView.isUserInteractionEnabled = true
        
        lottieAnimationView.logHierarchyKeypaths()
        // let layer3GroupOnefillKeyPath = AnimationKeypath(keypath: "Layer 3.Group 1.Fill 1.Color")
        // let valueProvider = ColorValueProvider(UIColor.cyan.lottieColorValue)
        // lottieAnimationView.setValueProvider(valueProvider, keypath: layer3GroupOnefillKeyPath)
        let carLayer8Group2fillKeyPathLayer = AnimationKeypath(keypath: "Layer 8.Group 2.Group 3.Fill 1.Color")
        let nextColorProvider = ColorValueProvider(UIColor.red.lottieColorValue)
        lottieAnimationView.setValueProvider(nextColorProvider, keypath: carLayer8Group2fillKeyPathLayer)
        let carLayer8Group1fillKeyPathLayer = AnimationKeypath(keypath: "Layer 8.Group 1.Fill 1.Color")
        lottieAnimationView.setValueProvider(nextColorProvider, keypath: carLayer8Group1fillKeyPathLayer)
        lottieAnimationView.frame = viewStartFrame
    }
    
    @objc func reloadAnimation() {
        UIView.animate(withDuration: 1.25, animations:  {
            self.lottieAnimationView.frame = self.viewStartFrame
        }, completion: { _ in
            self.lottieAnimationView.reloadImages()
            UIView.animate(withDuration: self.lottieAnimationView.animation?.duration ?? 5.0, animations:  {
                self.lottieAnimationView.frame = self.viewFinalFrame
                self.lottieAnimationView.play()
            })
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startAnimation()
    }

    private func startAnimation() {
        UIView.animate(withDuration: 1.0, delay: .zero, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, animations: {
            self.titleLabel.frame = CGRect(
                x: 20,
                y: 425.0,
                width: self.view.frame.width - 40,
                height: 50.0
            )
        }) { _ in
            UIView.animate(withDuration: 0.75, animations: {
                self.titleLabel.frame = CGRect(
                    x: 20,
                    y: 390.0,
                    width: self.view.frame.width - 40,
                    height: 50.0
                )
            }) { _ in
                UIView.animate(withDuration: 0.5, animations: {
                self.titleLabel.frame = CGRect(
                    x: 20,
                    y: 400.0,
                    width: self.view.frame.width - 40,
                    height: 50.0
                )
                }) { _ in
                    UIView.animate(withDuration: self.lottieAnimationView.animation?.duration ?? 5.0) {
                        self.lottieAnimationView.frame = self.viewFinalFrame
                        self.lottieAnimationView.play()
                    }
                }
            }
        }
    }
    
    
}
