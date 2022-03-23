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
import ReplayKit

class ViewController: UIViewController, ARSessionDelegate, DataReturn, RPPreviewViewControllerDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var addQaButton: UIBarButtonItem!
    @IBOutlet weak var resetQaButton: UIBarButtonItem!
    @IBOutlet weak var initializeButton: UIBarButtonItem!
    @IBOutlet weak var switchRecordButton: UIButton!
    
    var currentHandPoseObservation: VNHumanHandPoseObservation?
    var viewWidth:Int = 0
    var viewHeight:Int = 0
    //var player:AVAudioPlayer?
    var seManager:SEManager!
    var barButtonColor = UIColor.init(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
    
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
        let qaNode1 = QaNode(question: "今日は何日?", answer: "\(self.getToday())", initPosition: SCNVector3(0,0.07,-0.3))
        sceneView.scene.rootNode.addChildNode(qaNode1)
    }
    
    // 本日日付取得処理
    func getToday() -> String{
        let dt = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy/MM/dd", options: 0, locale: Locale(identifier: Locale.preferredLanguages.first!))
        return dateFormatter.string(from: dt)
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
    
    // ARジェスチャー
    func Answer(handPoseObservation: VNHumanHandPoseObservation) {
        guard let indexFingerTip = try? handPoseObservation.recognizedPoints(.all)[.indexTip],indexFingerTip.confidence > 0.3 else { return }
        let indexTip = VNImagePointForNormalizedPoint(CGPoint(x: indexFingerTip.location.x, y:1-indexFingerTip.location.y), viewWidth,  viewHeight)
        
        guard let nodeHitTest = sceneView.hitTest(indexTip, options: nil).first else { return }
        guard let nodeHit = nodeHitTest.node as? QaNode else { return }
        
        if !nodeHit.isAnswered {
            nodeHit.answerQa()
            self.playSound()
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
    
    // ＋ボタンを押した時の処理
    @IBAction func addNewQa(_ sender: Any) {
        let newNode = QaNode(initPosition: SCNVector3(0,0.1,-0.3))
        self.openEditModal(qaNode: newNode, mode: ModalMode.new)
    }
    
    // reset処理
    @IBAction func resetQA(_ sender: Any) {
        for node in sceneView.scene.rootNode.childNodes {
            guard let qaNode = node as? QaNode else { continue }
            qaNode.resetQa()
        }
    }
    // 編集モーダルを開く
    func openEditModal(qaNode: QaNode,mode:ModalMode){
        // open edit modal
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
            sceneView.scene.rootNode.addChildNode(qaNode)
        }
    }
    
    // 録画開始・録画停止
    @IBAction func switchRecording(_ sender: Any) {
        print("record")
        if RPScreenRecorder.shared().isRecording  {
            // 録画停止処理
            print("record stop")
            RPScreenRecorder.shared().stopRecording(handler: { (previewController, error) in
                if let previewController = previewController {
                    previewController.previewControllerDelegate = self
                    DispatchQueue.main.async {
                        self.present(previewController, animated: true, completion: nil)
                    }
                } else {
                    print("error stopping recording (was it running?)")
                }
            })
            self.switchShowBarButton(ishow: true)
        } else{
            // 録画開始処理
            print("record start")
            RPScreenRecorder.shared().isMicrophoneEnabled = true
            RPScreenRecorder.shared().startRecording(handler: { (error) in
                if let error = error {
                    debugPrint(#function, "recording something failed", error)
                }
            })
            
            self.switchShowBarButton(ishow: false)
        }
    }
    
    func switchShowBarButton(ishow:Bool){
        let barButtonColor = UIColor.init(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
        if ishow {
            self.switchRecordButton.setTitle("録画", for: .normal)
            self.addQaButton.isEnabled = true
            self.addQaButton.tintColor = barButtonColor
            self.resetQaButton.isEnabled = true
            self.resetQaButton.tintColor = barButtonColor
            self.initializeButton.isEnabled = true
            self.initializeButton.tintColor = barButtonColor
        } else{
            self.switchRecordButton.setTitle("停止", for: .normal)
            self.addQaButton.isEnabled = false
            self.addQaButton.tintColor = UIColor.clear
            self.resetQaButton.isEnabled = false
            self.resetQaButton.tintColor = UIColor.clear
            self.initializeButton.isEnabled = false
            self.initializeButton.tintColor = UIColor.clear
        }
        
    }
    
    // 録画プレビューのキャンセル処理
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        DispatchQueue.main.async { [unowned previewController] in
            previewController.dismiss(animated: true, completion: nil)
        }
    }
    
    // はじめからのボタンを押した時の処理
    @IBAction func initialize(_ sender: Any) {
        self.viewDidLoad()
    }
    
    // 音声再生
    func playSound() {
        do{
        try seManager.playSound(soundName: "gun.mp3")
        } catch {
            print(error)
        }
    }
}
