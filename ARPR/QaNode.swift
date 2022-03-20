//
//  QaNode.swift
//  ARPR
//
//  Created by 瀬戸川将夫 on 2022/03/16.
//

import SceneKit

class QaNode : SCNNode {
    var question:String?
    var answer:String?
    var initPosition:SCNVector3?
    var isAnswered : Bool = false
    var editingNode :QaNode?
    
    init(initPosition: SCNVector3) {
        super.init()
        self.initPosition = initPosition
        self.setText()
    }
        
    init(geometry: SCNGeometry) {
        super.init()
        self.geometry = geometry
    }
    
    init(question: String, answer: String, initPosition: SCNVector3) {
        super.init()
        self.question = question
        self.answer = answer
        self.position = initPosition
        self.setText()
    }
    
    // Xcode required this
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setText(){
        let text = SCNText(string: self.question, extrusionDepth: 0.5)
        text.font = UIFont(name: "HiraginoSans-W6", size: 1 )
        text.firstMaterial?.diffuse.contents = UIColor.green
        self.geometry = text
        
        let (min, max) = (self.boundingBox)
        let w = Float(max.x - min.x)
        let h = Float(max.y - min.y)
        self.pivot = SCNMatrix4MakeTranslation(w/2 + min.x, h/2 + min.y, 0)
        
        if let unwrapedInitPosition = self.initPosition {
            self.position = unwrapedInitPosition
        }
        self.scale = SCNVector3(0.02,0.02,0.02)
    }
    
    func reset(){
        self.isAnswered = false
        guard let textGeometry = self.geometry as? SCNText else { return }
        textGeometry.string = self.question
        textGeometry.firstMaterial?.diffuse.contents = UIColor.green
    }
    
    func answerQa(){
        let rotate = SCNAction.rotateBy(x: 2 * .pi, y: 0, z: 0, duration: 0.5)
        rotate.timingMode = .easeInEaseOut
        self.runAction(.sequence([rotate]))
        guard let textGeometry = self.geometry as? SCNText else { return }
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        textGeometry.string = self.answer
        self.isAnswered = true
    }
    
}
