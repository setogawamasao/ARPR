//
//  VirtualFaceContent.swift
//  face-tracking-spike
//
//  Created by 瀬戸川将夫 on 2022/03/27.
//

import UIKit
import SceneKit
import ARKit

protocol VirtualFaceContent {
    func update(withFaceAnchor: ARFaceAnchor)
}

typealias VirtualFaceNode = VirtualFaceContent & SCNNode
