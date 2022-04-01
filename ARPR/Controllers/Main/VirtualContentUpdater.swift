//
//  VirtualContentUpdater.swift
//  face-tracking-spike
//
//  Created by 瀬戸川将夫 on 2022/03/27.
//

import UIKit
import SceneKit
import ARKit

class VirtualContentUpdater: NSObject, ARSCNViewDelegate {
    
    var sceneView: ARSCNView?
    var node : SCNNode?
    
    func setSceneView(sceneView: ARSCNView, node:SCNNode){
        self.sceneView = sceneView
        self.node = node
    }

    //表示 or 更新用
    var virtualFaceNode: VirtualFaceNode? {
        didSet {
            setupFaceNodeContent()
        }
    }
    
    //セッションを再起動する必要がないように保持用
    private var faceNode: SCNNode?

    private let serialQueue = DispatchQueue(label: "com.example.serial-queue")

    //マスクのセットアップ
    private func setupFaceNodeContent() {
        // return //マスクを非表示
        guard let faceNode = faceNode else { return }

        //全ての子ノードを消去
        for child in faceNode.childNodes {
            child.removeFromParentNode()
        }
        //新しいノードを追加
        if let content = virtualFaceNode {
            faceNode.addChildNode(content)
        }
    }

    //MARK: - ARSCNViewDelegate
    //新しいARアンカーが設置された時に呼び出される
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        faceNode = node
        
        serialQueue.async {
            self.setupFaceNodeContent()
        }
    }

    //ARアンカーが更新された時に呼び出される
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let position = faceNode?.position {
            print(position)
            self.node?.position.x = position.x
            self.node?.position.y = position.y + 0.2
            self.node?.position.z = position.z
        }
        
        if let eulerAngles = faceNode?.eulerAngles {
            print(eulerAngles)
            self.node?.eulerAngles = eulerAngles
        }
    
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        virtualFaceNode?.update(withFaceAnchor: faceAnchor) //マスクをアップデートする
    }
}
