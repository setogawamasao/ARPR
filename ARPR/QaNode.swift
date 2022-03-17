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
        
    init(geometry: SCNGeometry) {
        super.init()
        self.geometry = geometry
    }
    
    init(question: String, answer: String, initPosition: SCNVector3) {
        super.init()
        self.question = question
        self.answer = answer
        self.position = initPosition
        self.create()
    }
    
    // Xcode required this
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func create(){
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
}
