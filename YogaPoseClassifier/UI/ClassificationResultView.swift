//
//  ClassificationResultView.swift
//  YogaPoseClassifier
//
//  Created by Paul on 2/21/22.
//

import UIKit

class ClassificationResultView: UIView {

    private var previewImageView: PoseImageView = PoseImageView(frame: .zero)

    private let treeImageView = UIImageView(image: #imageLiteral(resourceName: "tree"))
    private let triangleImageView  = UIImageView(image: #imageLiteral(resourceName: "triangle"))
    private let warriorImageView = UIImageView(image: #imageLiteral(resourceName: "warrior"))

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure() {
        backgroundColor = .init(white: 0.8, alpha: 1)
        configureSubviews()
    }

    func show(pose: Pose, on frame: CGImage, classificationResult: [PoseType: Double]) {
        previewImageView.show(poses: [pose], on: frame)
    }
}

private extension ClassificationResultView {
    func configureSubviews() {
        let sideLength = (min(frame.height, frame.width) - 16) / 3

        for imageView in [previewImageView, treeImageView, triangleImageView, warriorImageView] {
            addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.widthAnchor.constraint(equalToConstant: sideLength).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: sideLength).isActive = true
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 16
            imageView.contentMode = .scaleAspectFill
            imageView.alpha = 0.25
        }

        treeImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        treeImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        triangleImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        triangleImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
        warriorImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
        warriorImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true

        previewImageView.alpha = 0.75
        let previewCenterConstraints = [
            previewImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            previewImageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]
        for constraint in previewCenterConstraints {
            constraint.priority = .defaultHigh
            constraint.isActive = true
        }
    }
}
