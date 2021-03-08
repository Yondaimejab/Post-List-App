//
//  ImageCollectionViewCell.swift
//  ImagePostApp
//
//  Created by Joel Alcantara burgos on 6/3/21.
//

import UIKit
import Anchorage

class ImageCollectionViewCell: UICollectionViewCell {

    enum Constants {
        static let identifier = "ImageCollectionViewCellID"
        static let imagesHeight: CGFloat = 130.0
    }

    var imageView = UIImageView()

    func configureView(with tempImage: UIImage?) {
        imageView.image = tempImage
        imageView.isUserInteractionEnabled = true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        configure()
        buildInterface()
        displayDefaultLayout()
    }

    override func prepareForReuse() {
        imageView.gestureRecognizers?.removeAll()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        self.backgroundColor = .red
        imageView.contentMode = .scaleToFill
    }

    private func buildInterface() {
        addSubview(imageView)
    }

    private func displayDefaultLayout() {
        imageView.centerAnchors == centerAnchors
        imageView.heightAnchor == Constants.imagesHeight
        imageView.widthAnchor == Constants.imagesHeight
    }
}
