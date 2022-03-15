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
    var qas:[Qa] = [Qa(question: "年齢は?", answer: "32歳", position: SCNVector3(-0.05,0.25,-0.3)),
                    Qa(question: "学歴は?", answer: "院卒", position: SCNVector3(0.05,0.25,-0.3)),
                    Qa(question: "職業は?", answer: "SE", position: SCNVector3(-0.05,-0.05,-0.3)),
                    Qa(question: "年収は?", answer: "600", position: SCNVector3(0.05,-0.05,-0.3))]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView = ARSCNView(frame: view.bounds)
        view.addSubview(sceneView)
        viewWidth = Int(sceneView.bounds.width)
        viewHeight = Int(sceneView.bounds.height)
        
        // Set the view's delegate
        //sceneView.delegate = self
        
        
        let config = ARFaceTrackingConfiguration()
        sceneView.session.delegate = self
        sceneView.session.run(config, options: [.removeExistingAnchors])
        
        
        // Show statistics such as fps and timing information
//        sceneView.showsStatistics = true
        
        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
//        sceneView.scene = scene
        
        // ライトの追加
        sceneView.autoenablesDefaultLighting = true
        
        for qa in qas {
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
    
}
