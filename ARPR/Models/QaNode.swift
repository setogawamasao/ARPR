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
    var textNode:SCNNode?
    var textDepth = 0.01
    var questionColor:UIColor = UIColor.green
    var answerColor:UIColor = UIColor.red
    var soundName = "gun.mp3"
    var textScale:Float = 0.03
    var offset = SCNVector3(0,0,0)
    var isMoved = false
    var isAnswering = false
    
    init(initPosition: SCNVector3) {
        super.init()
        self.initPosition = initPosition
    }
    
    init(question: String, answer: String, initPosition: SCNVector3) {
        super.init()
        self.question = question
        self.answer = answer
        self.position = initPosition

        initializeNode()
    }
    
    // Xcode required this
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initializeNode(){
        let textNode = SCNNode()
        let text = SCNText(string: self.question, extrusionDepth: self.textDepth)
        text.font = UIFont(name: "HiraginoSans-W6", size: 1 )
        text.firstMaterial?.diffuse.contents = self.questionColor
        textNode.geometry = text
        textNode.scale = SCNVector3(self.textScale,self.textScale,0.99)
        self.textNode = textNode
        self.geometry = SCNBox()
        self.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 255, green: 255, blue: 255, alpha: 0)
        self.centerPivot()
        
        if let unwrapedInitPosition = self.initPosition {
            self.position = unwrapedInitPosition
        }
        self.addChildNode(textNode)
    }
    
    func resetQa(){
        guard let textNode = self.textNode ,
              let textGeometry = textNode.geometry as? SCNText else { return }
        textGeometry.string = self.question
        textGeometry.firstMaterial?.diffuse.contents = self.questionColor
        self.centerPivot()
        self.isAnswered = false
    }
    
    func answerQa(){
        let rotate = SCNAction.rotateBy(x: 2 * .pi, y: 0, z: 0, duration: 0.5)
        rotate.timingMode = .easeInEaseOut
        self.runAction(.sequence([rotate]))
        
        guard let textNode = self.textNode ,
              let textGeometry = textNode.geometry as? SCNText else { return }
        textGeometry.string = self.answer
        textGeometry.firstMaterial?.diffuse.contents = self.answerColor
        self.centerPivot()
        self.isAnswered = true
        
    }
    
    func centerPivot(){
        guard let textNode = self.textNode else { return }
        
        let (min, max) = (textNode.boundingBox)
        let w = Float(max.x - min.x)
        let h = Float(max.y - min.y)
        textNode.pivot = SCNMatrix4MakeTranslation(w/2 + min.x, h/2 + min.y, 0)
        
        guard let boxGeometry = self.geometry as? SCNBox else { return }
        boxGeometry.width = CGFloat(w * textNode.scale.x)
        boxGeometry.height =  CGFloat(h * textNode.scale.y)
        boxGeometry.length = textDepth
    }
}
