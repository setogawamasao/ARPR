//
//  Mask.swift
//  face-tracking-spike
//
//  Created by 瀬戸川将夫 on 2022/03/27.
//

import UIKit
import SceneKit
import ARKit

class Mask: SCNNode, VirtualFaceContent {

    init(geometry: ARSCNFaceGeometry) {
        let material = geometry.firstMaterial //初期化
        material?.diffuse.contents = UIColor.red //マスクの色
        material?.lightingModel = .physicallyBased //オブジェクトの照明のモデル

        super.init()
        self.geometry = geometry
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }

    //ARアンカーがアップデートされた時に呼ぶ
    func update(withFaceAnchor anchor: ARFaceAnchor) {
        guard let faceGeometry = geometry as? ARSCNFaceGeometry else { return }
        faceGeometry.update(from: anchor.geometry)
        faceGeometry.firstMaterial?.diffuse.contents = getRundomUIColor()
    }
}
