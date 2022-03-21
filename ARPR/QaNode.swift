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
    
    init(initPosition: SCNVector3) {
        super.init()
        self.initPosition = initPosition
        //self.setText()
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

        // text node 作成
        
        let textNode = SCNNode()
        let text = SCNText(string: self.question, extrusionDepth: self.textDepth)
        text.font = UIFont(name: "HiraginoSans-W6", size: 1 )
        text.firstMaterial?.diffuse.contents = UIColor.green
        textNode.geometry = text
        textNode.scale = SCNVector3(0.02,0.02,0.99)
        
        let (min, max) = (textNode.boundingBox)
        let w = Float(max.x - min.x)
        let h = Float(max.y - min.y)
        textNode.pivot = SCNMatrix4MakeTranslation(w/2 + min.x, h/2 + min.y, 0)
        self.textNode = textNode
        
        self.geometry = SCNBox(width: CGFloat(w * textNode.scale.x),
                               height: CGFloat(h * textNode.scale.y),
                               length: self.textDepth, chamferRadius: 0)
        self.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 255, green: 255, blue: 255, alpha: 0.5)
        
        if let unwrapedInitPosition = self.initPosition {
            self.position = unwrapedInitPosition
        }
        
        self.addChildNode(textNode)
        //self.setText()
    }
    
    // Xcode required this
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    func setText(){
//        let text = SCNText(string: self.question, extrusionDepth: 0.5)
//        text.font = UIFont(name: "HiraginoSans-W6", size: 1 )
//        text.firstMaterial?.diffuse.contents = UIColor.green
//        self.geometry = text
//
//        let (min, max) = (self.boundingBox)
//        let w = Float(max.x - min.x)
//        let h = Float(max.y - min.y)
//        self.pivot = SCNMatrix4MakeTranslation(w/2 + min.x, h/2 + min.y, 0)
//
//        if let unwrapedInitPosition = self.initPosition {
//            self.position = unwrapedInitPosition
//        }
//        self.scale = SCNVector3(0.02,0.02,0.02)
//    }
    
    func reset(){
        self.isAnswered = false
        guard let textNode = self.textNode ,
              let textGeometry = textNode.geometry as? SCNText else { return }
        textGeometry.string = self.question
        
        let (min, max) = (textNode.boundingBox)
        let w = Float(max.x - min.x)
        let h = Float(max.y - min.y)
        textNode.pivot = SCNMatrix4MakeTranslation(w/2 + min.x, h/2 + min.y, 0)
        
        guard let boxGeometry = self.geometry as? SCNBox else { return }
        boxGeometry.width = CGFloat(w * textNode.scale.x)
        boxGeometry.height =  CGFloat(h * textNode.scale.y)
        
        textGeometry.firstMaterial?.diffuse.contents = UIColor.green
    }
    
    func answerQa(){
        print("answerQa call")
        // change action
        let rotate = SCNAction.rotateBy(x: 2 * .pi, y: 0, z: 0, duration: 0.5)
        rotate.timingMode = .easeInEaseOut
        self.runAction(.sequence([rotate]))
        
        
        guard let textNode = self.textNode ,
              let textGeometry = textNode.geometry as? SCNText else { return }
        
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        textGeometry.string = self.answer
        
        let (min, max) = (textNode.boundingBox)
        let w = Float(max.x - min.x)
        let h = Float(max.y - min.y)
        textNode.pivot = SCNMatrix4MakeTranslation(w/2 + min.x, h/2 + min.y, 0)
        
        guard let boxGeometry = self.geometry as? SCNBox else { return }
        boxGeometry.width = CGFloat(w * textNode.scale.x)
        boxGeometry.height =  CGFloat(h * textNode.scale.y)
        
        self.isAnswered = true
    }
    
}
