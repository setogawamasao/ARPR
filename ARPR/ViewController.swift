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

class ViewController: UIViewController, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var currentHandPoseObservation: VNHumanHandPoseObservation?
    var viewWidth:Int = 0
    var viewHeight:Int = 0
    struct Qa {
        var question : String
        var answer : String
        var position : SCNVector3
        var isAnswered : Bool = false
    }
    var qas:[Qa] = []
    
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
        sceneView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTapped(_:))))
        
        // ライトの追加
        sceneView.autoenablesDefaultLighting = true
        
        // 初期QAの追加
        self.AddText(qa:Qa(question: "年齢は?", answer: "32歳", position: SCNVector3(-0.05,0.25,-0.3)))
        self.AddText(qa:Qa(question: "学歴は?", answer: "院卒", position: SCNVector3(0.05,0.25,-0.3)))
        self.AddText(qa:Qa(question: "職業は?", answer: "SE", position: SCNVector3(-0.05,-0.05,-0.3)))
        self.AddText(qa:Qa(question: "年収は?", answer: "600", position: SCNVector3(0.05,-0.05,-0.3)))
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
            getHandPosition(handPoseObservation: observation)
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
        guard let nodeHitTest = self.sceneView.hitTest(location, options: nil).first else {
            // no hit object -> add new qa object
            let addPlane = SCNVector3(x: 0, y: 0, z: -0.3)
            guard let cameraNode = sceneView.pointOfView else { return }
            let pointInWorld = cameraNode.convertPosition(addPlane, to: nil)
            var screenPosition = sceneView.projectPoint(pointInWorld)
            screenPosition.x = Float(location.x)
            screenPosition.y = Float(location.y)
            let newPosition = sceneView.unprojectPoint(screenPosition)
            self.AddText(qa:Qa(question: "追加した?", answer: "追加しました", position: newPosition))
            return
        }
        
        
        // hit object -> edit qa object
        print("exist node");
        
    }
    
    func getHandPosition(handPoseObservation: VNHumanHandPoseObservation) {
        guard let indexFingerTip = try? handPoseObservation.recognizedPoints(.all)[.indexTip],
              indexFingerTip.confidence > 0.3 else {return}
        let indexTip = VNImagePointForNormalizedPoint(CGPoint(x: indexFingerTip.location.x, y:1-indexFingerTip.location.y), viewWidth,  viewHeight)
        
        guard let nodeHitTest = sceneView.hitTest(indexTip, options: nil).first else { return }
        let nodeHit = nodeHitTest.node
        
        if let textGeometry = nodeHit.geometry as? SCNText {
            var q = qas.filter{$0.question == textGeometry.string as? String}
            
            if q.isEmpty {
                print("empty")
                return
            }
            
            if !q[0].isAnswered {
                let rotate = SCNAction.rotateBy(x: 2 * .pi, y: 0, z: 0, duration: 0.5)
                rotate.timingMode = .easeInEaseOut
                nodeHit.runAction(.sequence([rotate]))
                
                textGeometry.firstMaterial?.diffuse.contents = UIColor.red
                textGeometry.string = q[0].answer
                q[0].isAnswered = true
            }
        }
    }
    
    func AddText(qa:Qa){
        qas.append(qa)
        let text = SCNText(string: qa.question, extrusionDepth: 0.5)
        text.font = UIFont(name: "HiraginoSans-W6", size: 1 )
        text.firstMaterial?.diffuse.contents = UIColor.green
        let textNode = SCNNode(geometry: text)
        
        let (min, max) = (textNode.boundingBox)
        let w = Float(max.x - min.x)
        let h = Float(max.y - min.y)
        textNode.pivot = SCNMatrix4MakeTranslation(w/2 + min.x, h/2 + min.y, 0)
        textNode.position = qa.position
        textNode.scale = SCNVector3(0.02,0.02,0.02)
        
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
}
