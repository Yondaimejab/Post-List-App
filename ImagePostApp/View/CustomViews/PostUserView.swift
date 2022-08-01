//
//  PostUserView.swift
//  ImagePostApp
//
//  Created by Joel Alcantara burgos on 6/3/21.
//

import Foundation
import UIKit
import Anchorage
import Combine
import SkeletonView

class PostUserView: UIView {

    // Views
    let containerStackView = UIStackView()
    let profilePictureContainerView = UIView()
    let profilePicture = UIImageView()
    let verticalUserInfoContainerView = UIStackView()
    let userNameLabel = UILabel()
    let userEmailLabel = UILabel()
    let labelContainerView = UIView()
    let dateLabel = UILabel()

    // Properties
    var imageLoadingSubscriber: Cancellable?

    override init(frame: CGRect) {
        super.init(frame: frame)

        configure()
        buildInterface()
        displayDefaultLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init With coder not implemented")
    }

    private func configure() {
        containerStackView.axis = .horizontal
        containerStackView.spacing = 8

        verticalUserInfoContainerView.axis = .vertical
        verticalUserInfoContainerView.spacing = 2


        profilePicture.layer.masksToBounds = true
        userEmailLabel.font = .systemFont(ofSize: 12, weight: .medium)
        dateLabel.font = .systemFont(ofSize: 18)
        userEmailLabel.textColor = .darkGray
        userNameLabel.textColor = .darkGray
        dateLabel.textColor = .darkGray
        dateLabel.textAlignment = .center

        isSkeletonable = true
        containerStackView.isSkeletonable = true
        profilePicture.isSkeletonable = true
        verticalUserInfoContainerView.isSkeletonable = true
        userNameLabel.isSkeletonable = true
        userEmailLabel.isSkeletonable = true
        dateLabel.isSkeletonable = true
    }

    private func buildInterface() {
        addSubview(containerStackView)
        containerStackView.addArrangedSubview(profilePictureContainerView)
        profilePictureContainerView.addSubview(profilePicture)
        containerStackView.addArrangedSubview(verticalUserInfoContainerView)
        containerStackView.addArrangedSubview(labelContainerView)
        labelContainerView.addSubview(dateLabel)
        verticalUserInfoContainerView.addArrangedSubview(userNameLabel)
        verticalUserInfoContainerView.addArrangedSubview(userEmailLabel)
    }

    private func displayDefaultLayout() {
        containerStackView.edgeAnchors == edgeAnchors
        profilePictureContainerView.widthAnchor == 50
        profilePicture.widthAnchor == profilePictureContainerView.widthAnchor * 0.7
        profilePicture.heightAnchor == profilePictureContainerView.heightAnchor * 0.8
        profilePictureContainerView.centerAnchors == profilePicture.centerAnchors
        userEmailLabel.heightAnchor == 20
        labelContainerView.widthAnchor == 50
        dateLabel.centerYAnchor == labelContainerView.centerYAnchor
        dateLabel.trailingAnchor == labelContainerView.trailingAnchor - 5
    }

    func configureView(for user: UsersUIViewViewModel) {
        imageLoadingSubscriber = profilePicture.loadImageFrom(url: user.imageUrl)
            .sink(receiveCompletion: ( { completion in
                switch completion {
                case .failure(let error): print("=== Some Error has happend \(error.localizedDescription) ===")
                case .finished: print("Success")
                }
            } ), receiveValue: { [weak self] (imageLoaded) in
                guard let self = self else { return }
                guard imageLoaded else { return self.profilePicture.image = .placeholder }
                self.profilePicture.layer.cornerRadius = 17
                self.userNameLabel.text = user.name
                self.userEmailLabel.text = user.email
                self.dateLabel.text = user.date.capitalized
            })
    }
}
