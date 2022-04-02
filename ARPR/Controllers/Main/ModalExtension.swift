//
//  ModalExtension.swift
//  ARPR
//
//  Created by 瀬戸川将夫 on 2022/03/28.
//

import UIKit

extension ViewController: DataReturn {
    // 編集モーダルを開く
    func openEditModal(qaNode: QaNode,mode:ModalMode){
        if let editModalViewController = self.storyboard?.instantiateViewController(withIdentifier: "EditModal") as? EditModalViewController
        {
            editModalViewController.modalPresentationStyle = .popover
            editModalViewController.delegate = self
            if let popover = editModalViewController.popoverPresentationController {
                let sheet = popover.adaptiveSheetPresentationController
                sheet.detents = [.medium(),.large()]
                sheet.prefersGrabberVisible = true // ハンドルを表示
            }
        
            editModalViewController.editedNode = qaNode
            editModalViewController.mode = mode
            present(editModalViewController, animated: true, completion: nil)
        }
    }
    
    // モーダルを閉じた時の値を受け取るdelegate
    func returnData(qaNode: QaNode, mode: ModalMode) {
        if mode == ModalMode.new {
            qaNode.initializeNode()
            guard let cameraNode = sceneView.pointOfView else { return }
            guard let facePosition = self.facePosition else {return}
            let facePositionInCamera = sceneView.scene.rootNode.convertPosition(facePosition, to: cameraNode)
            let nodeInCamera = sceneView.scene.rootNode.convertPosition(qaNode.position, to: cameraNode)
            qaNode.offset.x = nodeInCamera.x - facePositionInCamera.x
            qaNode.offset.y = nodeInCamera.y - facePositionInCamera.y
            
            sceneView.scene.rootNode.addChildNode(qaNode)
        }
    }
}
