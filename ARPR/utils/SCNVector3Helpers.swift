//
//  CGPpintHelpers.swift
//  ARPR
//
//  Created by 瀬戸川将夫 on 2022/04/01.
//

import SceneKit

extension SCNVector3 {
    func distance(from point: SCNVector3) -> Float {
        return sqrt(pow(point.x - x,2) + pow(point.y - y,2) + pow(point.z - z,2))
    }
}
