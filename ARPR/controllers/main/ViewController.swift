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

class ViewController: UIViewController, ARSessionDelegate  {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var addQaButton: UIBarButtonItem!
    @IBOutlet weak var resetQaButton: UIBarButtonItem!
    @IBOutlet weak var initializeButton: UIBarButtonItem!
    @IBOutlet weak var switchRecordButton: UIButton!
    
    var currentHandPoseObservation: VNHumanHandPoseObservation?
    var viewWidth:Int = 0
    var viewHeight:Int = 0
    var seManager:SEManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView = ARSCNView(frame: view.bounds)
        view.addSubview(sceneView)
        viewWidth = Int(sceneView.bounds.width)
        viewHeight = Int(sceneView.bounds.height)
        let config = ARFaceTrackingConfiguration()
        sceneView.session.delegate = self
        sceneView.session.run(config, options: [.removeExistingAnchors])
        
        seManager = SEManager.sharedInstance
        
        // ドラッグ＆ドロップの画面上のジェスチャーを検知
        sceneView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(ViewController.handleMove(_:))))
        // タップの画面上のジェスチャーを検知
        sceneView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTapped(_:))))
        // ライトの追加
        sceneView.autoenablesDefaultLighting = true
        // 初期QAの追加
        let qaNode1 = QaNode(question: "今日は何日?", answer: "\(getToday())", initPosition: SCNVector3(0,0.07,-0.3))
        sceneView.scene.rootNode.addChildNode(qaNode1)
    }
    
    // フレームごとの処理
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
    
    // ARジェスチャー
    func Answer(handPoseObservation: VNHumanHandPoseObservation) {
        guard let indexFingerTip = try? handPoseObservation.recognizedPoints(.all)[.indexTip],indexFingerTip.confidence > 0.3 else { return }
        let indexTip = VNImagePointForNormalizedPoint(CGPoint(x: indexFingerTip.location.x, y:1-indexFingerTip.location.y), viewWidth,  viewHeight)
        
        guard let nodeHitTest = sceneView.hitTest(indexTip, options: nil).first else { return }
        guard let nodeHit = nodeHitTest.node as? QaNode else { return }
        
        if !nodeHit.isAnswered {
            nodeHit.answerQa()
            self.playSound(soundName: nodeHit.soundName)
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
