//
//  ViewController.swift
//  YogaPoseClassifier
//
//  Created by Paul on 2/19/22.
//

import UIKit

class ViewController: UIViewController {
    /// The view the controller uses to visualize the detected poses.
    private var resultView: ClassificationResultView!

    private let videoCapture = VideoCapture()

    private var poseNet: PoseNet!

    /// The frame the PoseNet model is currently making pose predictions from.
    private var currentFrame: CGImage?

    /// The set of parameters passed to the pose builder when detecting poses.
    private let poseBuilderConfiguration = PoseBuilderConfiguration(jointConfidenceThreshold: 0.4, poseConfidenceThreshold: 0.3, matchingJointDistance: 40, localSearchRadius: 3, maxPoseCount: 1, adjacentJointOffsetRefinementSteps: 3)

    override func viewDidLoad() {
        super.viewDidLoad()

        // For convenience, the idle timer is disabled to prevent the screen from locking.
        UIApplication.shared.isIdleTimerDisabled = true

        do {
            poseNet = try PoseNet()
        } catch {
            fatalError("Failed to load model. \(error.localizedDescription)")
        }

        setupViews()

        poseNet.delegate = self
        setupAndBeginCapturingVideoFrames()
    }

    override func viewWillDisappear(_ animated: Bool) {
        videoCapture.stopCapturing {
            super.viewWillDisappear(animated)
        }
    }

    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        // Reinitilize the camera to update its output stream with the new orientation.
        setupAndBeginCapturingVideoFrames()
    }
}

private extension ViewController {
    func setupViews() {
        resultView = ClassificationResultView(frame: view.bounds)
        view.addSubview(resultView)
        resultView.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: resultView.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: resultView.bottomAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: resultView.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: resultView.trailingAnchor).isActive = true

        resultView.configure()
    }

    func setupAndBeginCapturingVideoFrames() {
        videoCapture.setUpAVCapture { error in
            if let error = error {
                print("Failed to setup camera with error \(error)")
                return
            }

            self.videoCapture.delegate = self

            self.videoCapture.startCapturing()
        }
    }

}

// MARK: - VideoCaptureDelegate

extension ViewController: VideoCaptureDelegate {
    func videoCapture(_ videoCapture: VideoCapture, didCaptureFrame capturedImage: CGImage?) {
        guard currentFrame == nil else {
            return
        }
        guard let image = capturedImage else {
            fatalError("Captured image is null")
        }

        currentFrame = image
        poseNet.predict(image)
    }
}

// MARK: - PoseNetDelegate

extension ViewController: PoseNetDelegate {
    func poseNet(_ poseNet: PoseNet, didPredict predictions: PoseNetOutput) {
        defer {
            // Release `currentFrame` when exiting this method.
            self.currentFrame = nil
        }

        guard let currentFrame = currentFrame else {
            return
        }

        let poseBuilder = PoseBuilder(output: predictions,
                                      configuration: poseBuilderConfiguration,
                                      inputImage: currentFrame)

        let pose = poseBuilder.pose

        let result = PoseClassifier.classify(pose: pose)
        resultView.show(pose: pose, on: currentFrame, classificationResult: result)
    }
}

