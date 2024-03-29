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
    var imagePresenterDelegate: ImagePresenter?

    func configureView(with tempImage: UIImage?, delegate: ImagePresenter?) {
        imagePresenterDelegate = delegate
        imageView.image = tempImage
        imageView.isUserInteractionEnabled = true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        buildInterface()
        displayDefaultLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        self.backgroundColor = .red
        imageView.contentMode = .scaleToFill
        imageView.isSkeletonable = true
        imageView.clipsToBounds = true
        imageView.layer.maskedCorners = .allCorners
        imageView.layer.cornerRadius = 12.0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(gesture:)))
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
    }

    private func buildInterface() {
        contentView.addSubview(imageView)
    }

    private func displayDefaultLayout() {
        imageView.centerAnchors == contentView.centerAnchors
        imageView.heightAnchor == Constants.imagesHeight
        imageView.widthAnchor == Constants.imagesHeight
    }
    
    @objc func imageTapped(gesture: UITapGestureRecognizer) {
        guard let imageView = gesture.view as? UIImageView else { return }
        imagePresenterDelegate?.presentImageViewWithBlur(imageView)
//        guard let image = imageView.image else { return }
//        imagePresenterDelegate?.presentImageWithBlur(for: image)
    }
}
