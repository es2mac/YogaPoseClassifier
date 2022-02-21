//
//  PoseClassifier.swift
//  YogaPoseClassifier
//
//  Created by Paul on 2/21/22.
//

import Foundation

enum PoseType {
    case tree, triangle, warrior
}

struct PoseClassifier {
    static func classify(pose: Pose) -> [PoseType: Double] {
        return [.tree: 0,
                .triangle: 0,
                .warrior: 0]
    }
}
