//
//  ViewController.swift
//  ARPR
//
//  Created by 瀬戸川将夫 on 2022/03/12.
//

import UIKit
import SceneKit
import ARKit
import Vision

class ViewController: UIViewController, ARSessionDelegate, DataReturn {

    @IBOutlet var sceneView: ARSCNView!
    var currentHandPoseObservation: VNHumanHandPoseObservation?
    var viewWidth:Int = 0
    var viewHeight:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView = ARSCNView(frame: view.bounds)
        view.addSubview(sceneView)
        viewWidth = Int(sceneView.bounds.width)
        viewHeight = Int(sceneView.bounds.height)
        
        let config = ARFaceTrackingConfiguration()
        sceneView.session.delegate = self
        sceneView.session.run(config, options: [.removeExistingAnchors])
        
        // ドラッグ＆ドロップの画面上のジェスチャーを検知
        sceneView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(ViewController.handleMove(_:))))
        // タップの画面上のジェスチャーを検知
        sceneView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTapped(_:))))
        // ライトの追加
        sceneView.autoenablesDefaultLighting = true
        // 初期QAの追加
        let qaNode1 = QaNode(question: "年齢は?", answer: "32歳", initPosition: SCNVector3(0,0,-0.3))
        sceneView.scene.rootNode.addChildNode(qaNode1)
        
//        self.AddText(question: "学歴は?", answer: "院卒", position: SCNVector3(0.05,0.25,-0.3))
//        self.AddText(question: "職業は?", answer: "SE", position: SCNVector3(-0.05,-0.05,-0.3))
//        self.AddText(question: "年収は?", answer: "600", position: SCNVector3(0.05,-0.05,-0.3))
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let pixelBuffer = frame.capturedImage
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            let handPoseRequest = VNDetectHumanHandPoseRequest()
            handPoseRequest.maximumHandCount = 1
            handPoseRequest.revision = VNDetectHumanHandPoseRequestRevision1
            
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,orientation: .right , options: [:])
            do {
                try handler.perform([handPoseRequest])
            } catch {
                assertionFailure("HandPoseRequest failed: \(error)")
            }
            
            guard let handPoses = handPoseRequest.results, !handPoses.isEmpty else { return }
            guard let observation = handPoses.first else { return }
            self.Answer(handPoseObservation: observation)
        }
    }
    
    // AR ジェスチャー
    func Answer(handPoseObservation: VNHumanHandPoseObservation) {
        guard let indexFingerTip = try? handPoseObservation.recognizedPoints(.all)[.indexTip],indexFingerTip.confidence > 0.3 else { return }
        let indexTip = VNImagePointForNormalizedPoint(CGPoint(x: indexFingerTip.location.x, y:1-indexFingerTip.location.y), viewWidth,  viewHeight)
        
        guard let nodeHitTest = sceneView.hitTest(indexTip, options: nil).first else { return }
        guard let nodeHit = nodeHitTest.node as? QaNode else { return }
        
        if let textGeometry = nodeHit.geometry as? SCNText {
            if !nodeHit.isAnswered {
                let rotate = SCNAction.rotateBy(x: 2 * .pi, y: 0, z: 0, duration: 0.5)
                rotate.timingMode = .easeInEaseOut
                nodeHit.runAction(.sequence([rotate]))
                textGeometry.firstMaterial?.diffuse.contents = UIColor.red
                textGeometry.string = nodeHit.answer
                nodeHit.isAnswered = true
            }
        }
    }
    
    // ドラッグ&ドロップのジェスチャーの挙動
    @objc func handleMove(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self.sceneView)
        guard let nodeHitTest = self.sceneView.hitTest(location, options: nil).first else {
            print("no node");
            return
        }
        let nodeHit = nodeHitTest.node
        let worldTransform = nodeHitTest.simdWorldCoordinates
        nodeHit.position = SCNVector3(worldTransform.x, worldTransform.y, -0.3)
    }
    
    // タップのジェスチャーの挙動
    @objc func handleTapped(_ gesture: UIHoverGestureRecognizer) {
        let location = gesture.location(in: self.sceneView)
        var newPosition:SCNVector3?
        var isNode = false
        var editedNode: QaNode?
        
        
        if let hitNode = self.sceneView.hitTest(location, options: nil).first  {
            editedNode = hitNode.node as? QaNode
            isNode = true
        }
        else{
            // no hit object -> add new qa object
            let addPlane = SCNVector3(x: 0, y: 0, z: -0.3)
            guard let cameraNode = sceneView.pointOfView else { return }
            let pointInWorld = cameraNode.convertPosition(addPlane, to: nil)
            var screenPosition = sceneView.projectPoint(pointInWorld)
            screenPosition.x = Float(location.x)
            screenPosition.y = Float(location.y)
            newPosition = sceneView.unprojectPoint(screenPosition)
        }
        
        // open edit modal
        if let editModalViewController = self.storyboard?.instantiateViewController(withIdentifier: "EditModal") as? EditModalViewController
        {
            editModalViewController.modalPresentationStyle = .popover
            editModalViewController.delegate = self
            if let popover = editModalViewController.popoverPresentationController {
                let sheet = popover.adaptiveSheetPresentationController
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true // ハンドルを表示
            }
        
            if isNode {
                editModalViewController.editedNode = editedNode
                editModalViewController.mode = ModalMode.edit
            }
            else{
                editModalViewController.initPostition = newPosition
                editModalViewController.mode = ModalMode.new
            }

            

            present(editModalViewController, animated: true, completion: nil)
        }
        return
    }
    
    func returnData(qaNode: QaNode, mode: ModalMode) {
        if mode == ModalMode.new {
            sceneView.scene.rootNode.addChildNode(qaNode)
        }        
    }
    
}
