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
    var isAnswered : Bool = false
    
    init(geometry: SCNGeometry) {
        super.init()
        self.geometry = geometry
    }
    
    // Xcode required this
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
