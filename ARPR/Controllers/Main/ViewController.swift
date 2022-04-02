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

class ViewController: UIViewController, ARSessionDelegate, ARSCNViewDelegate  {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var addQaButton: UIBarButtonItem!
    @IBOutlet weak var resetQaButton: UIBarButtonItem!
    @IBOutlet weak var initializeButton: UIBarButtonItem!
    @IBOutlet weak var switchRecordButton: UIButton!
    
    var currentHandPoseObservation: VNHumanHandPoseObservation?
    var viewWidth:Int = 0
    var viewHeight:Int = 0
    var seManager = SEManager.sharedInstance
    let serialQueue1 = DispatchQueue(label: "main-session")
    let serialQueue2 = DispatchQueue(label: "face-tracking")
    let serialQueue3 = DispatchQueue(label: "face-tracking-add")
    var touchedNodeDistance :Float?
    var facePosition : SCNVector3?
    var isMoved = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView = ARSCNView(frame: view.bounds)
        view.addSubview(sceneView)
        viewWidth = Int(sceneView.bounds.width)
        viewHeight = Int(sceneView.bounds.height)
        let config = ARFaceTrackingConfiguration()
        sceneView.session.delegate = self
        sceneView.delegate = self
        sceneView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        
        // ドラッグ＆ドロップの画面上のジェスチャーを検知
        sceneView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(ViewController.handleMove(_:))))
        // タップの画面上のジェスチャーを検知
        sceneView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTapped(_:))))
        // ライトの追加
        sceneView.autoenablesDefaultLighting = true
        
    }
    
    // フレームごとの処理
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        serialQueue1.sync {
            for childNode in self.sceneView.scene.rootNode.childNodes {
                guard let qaNode = childNode as? QaNode else {continue}
                if let camera = self.sceneView.pointOfView {
                    if self.isMoved == false {
                        qaNode.eulerAngles = camera.eulerAngles  // カメラのオイラー角と同じにする
                    }
                }
            }
            
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
    }
    
    //新しいARアンカーが設置された時に呼び出される
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
       serialQueue3.async {
           // 初期QAの追加
           let qaNode1 = QaNode(question: "今日は何日?", answer: "\(getToday())", initPosition: node.position)
           self.sceneView.scene.rootNode.addChildNode(qaNode1)
       }
    }

    //ARアンカーが更新された時に呼び出される
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        serialQueue2.async {
            self.facePosition = node.position
            for childNode in self.sceneView.scene.rootNode.childNodes {
                guard let qaNode = childNode as? QaNode else {continue}
                if self.isMoved == false {
                    guard let cameraNode = self.sceneView.pointOfView else { return }
                    //qaNode.offset.z = -node.position.distance(from: cameraNode.position)
                    let offsetInWorld = cameraNode.convertPosition(qaNode.offset, to: nil)
                    
                    qaNode.position.x = node.position.x + offsetInWorld.x
                    qaNode.position.y = node.position.y + offsetInWorld.y
                    qaNode.position.z = node.position.z + offsetInWorld.z
                }
            }
        }
    }
    
    // ARジェスチャー
    func Answer(handPoseObservation: VNHumanHandPoseObservation) {
        guard let indexFingerTip = try? handPoseObservation.recognizedPoints(.all)[.indexTip],indexFingerTip.confidence > 0.3 else { return }
        let indexTip = VNImagePointForNormalizedPoint(CGPoint(x: indexFingerTip.location.x, y:1-indexFingerTip.location.y), viewWidth,  viewHeight)
        
        guard let nodeHitTest = sceneView.hitTest(indexTip, options: nil).first else { return }
        guard let nodeHit = nodeHitTest.node as? QaNode else { return }
        
        if !nodeHit.isAnswered {
            print("answed")
            nodeHit.answerQa()
            //self.playSound(soundName: nodeHit.soundName)
        }
    }
    
    // ドラッグ&ドロップのジェスチャーの挙動
    @objc func handleMove(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self.sceneView)
        guard let nodeHitTest = self.sceneView.hitTest(location, options: nil).first else {
            //print("no node");
            return
        }
        
        if let nodeHit = nodeHitTest.node as? QaNode{
            guard let cameraNode = sceneView.pointOfView else { return }
            if !self.isMoved {
                touchedNodeDistance = nodeHit.position.distance(from: cameraNode.position)
                self.isMoved  = true
            }
            guard let distance = touchedNodeDistance else { return }
            let addPlane = SCNVector3(x: 0, y: 0, z: -distance)
            let pointInWorld = cameraNode.convertPosition(addPlane, to: nil)
            var screenPosition = sceneView.projectPoint(pointInWorld)
            screenPosition.x = Float(location.x)
            screenPosition.y = Float(location.y)
            nodeHit.position = sceneView.unprojectPoint(screenPosition)
            
            // 指が離れた時
            if(gesture.state == UIGestureRecognizer.State.ended){
                self.isMoved = false
                guard let facePosition = self.facePosition else {return}
                let facePositionInCamera = sceneView.scene.rootNode.convertPosition(facePosition, to: cameraNode)
                let nodeHitInCamera = sceneView.scene.rootNode.convertPosition(nodeHit.position, to: cameraNode)
                nodeHit.offset.x = nodeHitInCamera.x - facePositionInCamera.x
                nodeHit.offset.y = nodeHitInCamera.y - facePositionInCamera.y
            }
        }
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
            guard let cameraNode = sceneView.pointOfView else { return }
            guard let facePosition = self.facePosition else {return}
            let addPlane = SCNVector3(x: 0, y: 0, z: -facePosition.distance(from: cameraNode.position))
            guard let cameraNode = sceneView.pointOfView else { return }
            let pointInWorld = cameraNode.convertPosition(addPlane, to: nil)
            var screenPosition = sceneView.projectPoint(pointInWorld)
            screenPosition.x = Float(location.x)
            screenPosition.y = Float(location.y)
            newPosition = sceneView.unprojectPoint(screenPosition)
        }
        
        // open edit modal
        if isNode {
            guard let editedNode = editedNode else {return}
            self.openEditModal(qaNode: editedNode, mode: ModalMode.update)
        }
        else{
            guard let newPosition = newPosition else {return}
            let newNode = QaNode(initPosition: newPosition)
            self.openEditModal(qaNode: newNode, mode: ModalMode.new)
        }
    }
    
    // はじめからのボタン押下時
    @IBAction func initialize(_ sender: Any) {
        self.viewDidLoad()
    }
    
    // resetボタン押下時
    @IBAction func resetQA(_ sender: Any) {
        for node in sceneView.scene.rootNode.childNodes {
            guard let qaNode = node as? QaNode else { continue }
            qaNode.resetQa()
        }
    }
    
    // ＋ボタン押下時
    @IBAction func addNewQa(_ sender: Any) {
        let newNode = QaNode(initPosition: SCNVector3(0,0.1,-0.3))
        self.openEditModal(qaNode: newNode, mode: ModalMode.new)
    }
}
