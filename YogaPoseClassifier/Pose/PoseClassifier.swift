//
//  PoseClassifier.swift
//  YogaPoseClassifier
//
//  Created by Paul on 2/21/22.
//

import Foundation
import CoreGraphics
import CoreMedia

enum PoseType {
    case tree, triangle, warrior
}

struct PoseClassifier {
    struct Result {
        let treeValue: Double
        let triangleValue: Double
        let warriorValue: Double
    }

    static func classify(pose: Pose) -> Result {
        guard pose[.leftHip].isValid,
              pose[.rightHip].isValid,
              pose.validJointCount() >= 8 else {
                  return Result(treeValue: 0, triangleValue: 0, warriorValue: 0)
              }

        return Result(treeValue: computeConfidence(pose: pose,
                                                   referencePose: treePose,
                                                   floorValue: 0.86),
                      triangleValue: computeConfidence(pose: pose,
                                                       referencePose: trianglePose,
                                                       floorValue: 0.48),
                      warriorValue: computeConfidence(pose: pose,
                                                      referencePose: warriorPose,
                                                      floorValue: 0.77))
    }
}

private func computeConfidence(pose: Pose, referencePose: Pose, floorValue: Double) -> Double {
    let centeredPose = pose.centeredToHip()
    let mirroredPose = centeredPose.mirrored()
    let rawValue = max(centeredPose.similarity(to: referencePose),
                       mirroredPose.similarity(to: referencePose))

    return raisedFloor(floorValue, value: rawValue)
}

/// Transforming a value from (floor, 1) to (0, 1)
private func raisedFloor(_ floor: Double, value: Double) -> Double {
    max(0, value - floor) / (1 - floor)
}

private extension Pose {
    static let interestedJointNames: [Joint.Name] = [
        .nose,
        .leftShoulder, .rightShoulder,
        .leftElbow, .rightElbow,
        .leftWrist, .rightWrist,
        .leftHip, .rightHip,
        .leftKnee, .rightKnee,
        .leftAnkle, .rightAnkle
    ]

    func validJointCount() -> Int {
        Pose.interestedJointNames.compactMap { joints[$0] }
        .filter(\.isValid)
        .count
    }

    func centeredToHip() -> Pose {
        let hipCenter: CGPoint = self[.leftHip].position.midpoint(to: self[.rightHip].position)

        var newPose = self
        for jointName in Pose.interestedJointNames {
            newPose[jointName] = self[jointName].shifted(center: hipCenter)
        }

        return newPose
    }

    func mirrored() -> Pose {
        var newPose = self
        
        for jointName in Pose.interestedJointNames {
            let joint = self[jointName].mirrored()
            newPose[joint.name] = joint
        }
        return newPose
    }

    /// Take the coordinates of the joints we're interested in the the poses
    /// and compute their cosine similarity
    func similarity(to otherPose: Pose) -> Double {
        var thisVector: [Double] = []
        var otherVector: [Double] = []
        for jointName in Pose.interestedJointNames {
            let thisJoint = self[jointName]
            if !thisJoint.isValid {
                continue
            }
            let otherJoint = otherPose[jointName]
            thisVector.append(thisJoint.position.x)
            thisVector.append(thisJoint.position.y)
            otherVector.append(otherJoint.position.x)
            otherVector.append(otherJoint.position.y)
        }

        let thisMagnitude = sqrt(thisVector.map { $0 * $0 }.reduce(0, +))
        let otherMagnitude = sqrt(otherVector.map { $0 * $0 }.reduce(0, +))
        let dotProduct = zip(thisVector, otherVector).map(*).reduce(0, +)

        return dotProduct / (thisMagnitude * otherMagnitude)
    }
}


private extension Joint {
    static let mirroredNames: [Name : Name] = [
        .nose: .nose,
        .leftEye: .rightEye,
        .rightEye: .leftEye,
        .leftEar: .rightEar,
        .rightEar: .leftEar,
        .leftShoulder: .rightShoulder,
        .rightShoulder: .leftShoulder,
        .leftElbow: .rightElbow,
        .rightElbow: .leftElbow,
        .leftWrist: .rightWrist,
        .rightWrist: .leftWrist,
        .leftHip: .rightHip,
        .rightHip: .leftHip,
        .leftKnee: .rightKnee,
        .rightKnee: .leftKnee,
        .leftAnkle: .rightAnkle,
        .rightAnkle: .leftAnkle
    ]

    func shifted(center: CGPoint) -> Joint {
        Joint(name: Joint.mirroredNames[name]!,
              cell: cell,
              position: position - center,
              confidence: confidence,
              isValid: isValid)
    }

    func mirrored() -> Joint {
        Joint(name: name,
              cell: cell,
              position: .init(x: -position.x, y: position.y),
              confidence: confidence,
              isValid: isValid)
    }
}

// MARK: - Reference "perfect poses"

private let treePose: Pose = {
    var pose = Pose()
    pose[.nose].position = .init(x: 16, y: -144)
    pose[.leftShoulder].position = .init(x: 35, y: -101)
    pose[.rightShoulder].position = .init(x: -25, y: -102)
    pose[.leftElbow].position = .init(x: 46, y: -47)
    pose[.rightElbow].position = .init(x: -33, y: -50)
    pose[.leftWrist].position = .init(x: 2, y: -84)
    pose[.rightWrist].position = .init(x: -2, y: -84)
    pose[.leftHip].position = .init(x: 19, y: 5)
    pose[.rightHip].position = .init(x: -19, y: -5)
    pose[.leftKnee].position = .init(x: 7, y: 96)
    pose[.rightKnee].position = .init(x: -55, y: 45)
    pose[.leftAnkle].position = .init(x: -3, y: 195)
    pose[.rightAnkle].position = .init(x: -2, y: 40)
    return pose
}()

private let trianglePose: Pose = {
    var pose = Pose()
    pose[.nose].position = .init(x: -111, y: -20)
    pose[.leftShoulder].position = .init(x: -70, y: -30)
    pose[.rightShoulder].position = .init(x: -73, y: 0)
    pose[.leftElbow].position = .init(x: -56, y: -82)
    pose[.rightElbow].position = .init(x: -57, y: 60)
    pose[.leftWrist].position = .init(x: -55, y: -132)
    pose[.rightWrist].position = .init(x: -58, y: 120)
    pose[.leftHip].position = .init(x: 7, y: -2)
    pose[.rightHip].position = .init(x: -7, y: 2)
    pose[.leftKnee].position = .init(x: 33, y: 55)
    pose[.rightKnee].position = .init(x: -50, y: 60)
    pose[.leftAnkle].position = .init(x: 65, y: 128)
    pose[.rightAnkle].position = .init(x: -92, y: 127)
    return pose
}()

private let warriorPose: Pose = {
    var pose = Pose()
    pose[.nose].position = .init(x: -12, y: -89)
    pose[.leftShoulder].position = .init(x: 25, y: -66)
    pose[.rightShoulder].position = .init(x: -15, y: -66)
    pose[.leftElbow].position = .init(x: 59, y: -59)
    pose[.rightElbow].position = .init(x: -57, y: -66)
    pose[.leftWrist].position = .init(x: 104, y: -61)
    pose[.rightWrist].position = .init(x: -102, y: -68)
    pose[.leftHip].position = .init(x: 15, y: 0)
    pose[.rightHip].position = .init(x: -15, y: -0)
    pose[.leftKnee].position = .init(x: 50, y: 40)
    pose[.rightKnee].position = .init(x: -69, y: 17)
    pose[.leftAnkle].position = .init(x: 90, y: 75)
    pose[.rightAnkle].position = .init(x: -71, y: 74)
    return pose
}()
