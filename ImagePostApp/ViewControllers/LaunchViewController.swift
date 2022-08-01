//
//  LaunchViewController.swift
//  ImagePostApp
//
//  Created by Joel Alcantara burgos on 6/3/21.
//

import UIKit

class LaunchViewController: UIViewController {

    // Constants
    enum Constants {
        static let startAnimationTime: Double = 1 //5
        static let homeSegue = "homeSegueIdentifier"
    }
    
    // Outlets
    @IBOutlet weak var IconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    private func setupViews() {
        self.titleLabel.layer.opacity = 0.0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startAnimation()
    }

    private func startAnimation() {
        UIView.animate(withDuration: Constants.startAnimationTime, animations: ({
            [weak self] in
            self?.IconImageView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: -12).scaledBy(x: 2, y: 2)
            self?.titleLabel.isHidden = false
            self?.titleLabel.layer.opacity = 1.0
        })) { (_) in
            self.performSegue(withIdentifier: Constants.homeSegue, sender: self)
        }
    }
}
