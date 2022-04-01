//
//  CGPpintHelpers.swift
//  ARPR
//
//  Created by 瀬戸川将夫 on 2022/04/01.
//

import CoreGraphics
import SceneKit

extension SCNVector3 {

//    static func midPoint(p1: CGPoint, p2: CGPoint) -> CGPoint {
//        return CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
//    }
    
    func distance(from point: SCNVector3) -> Float {
        return sqrt(pow(point.x - x,2) + pow(point.y - y,2) + pow(point.z - z,2))
    }
}
