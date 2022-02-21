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

    private let textView = UITextView() // Useful for troubleshooting

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

    func show(pose: Pose, on frame: CGImage, classificationResult: PoseClassifier.Result) {
        previewImageView.show(poses: [pose], on: frame)

        updateImageViews(result: classificationResult)
        updateTextView(result: classificationResult)
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

        previewImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        previewImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        previewImageView.alpha = 1

        treeImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        treeImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        triangleImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        triangleImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
        warriorImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
        warriorImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true

//        addSubview(textView)
//        textView.font = .systemFont(ofSize: 64)
//        textView.frame = .init(x: 0, y: 0, width: 1000, height: 300)
    }

    func updateImageViews(result: PoseClassifier.Result) {
        // Highlight the one with highest value by making it appear, using opacity to represent value
        // If all the values are small then keep them all faded
        let maxValue: Double = {
            let maxValue = [result.treeValue, result.triangleValue, result.warriorValue].max()!
            return maxValue >= 0.25 ? maxValue : 1
        }()
        let minAlphaValue = 0.25
        let maxAlphaValue = min(1, maxValue * 2.5)

        UIView.animate(withDuration: 0.5) { [treeImageView, triangleImageView, warriorImageView] in
            treeImageView.alpha = (result.treeValue < maxValue) ? minAlphaValue : maxAlphaValue
            triangleImageView.alpha = (result.triangleValue < maxValue) ? minAlphaValue : maxAlphaValue
            warriorImageView.alpha = (result.warriorValue < maxValue) ? minAlphaValue : maxAlphaValue
        }
    }

    func updateTextView(result: PoseClassifier.Result) {
        textView.text = """
            tree: \(result.treeValue)
            triangle: \(result.triangleValue)
            warrior: \(result.warriorValue)
            """
    }
}
