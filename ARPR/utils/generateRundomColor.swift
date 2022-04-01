//
//  generateRundomColor.swift
//  face-tracking-spike
//
//  Created by 瀬戸川将夫 on 2022/03/27.
//

import Foundation
import UIKit

func getRundomUIColor() -> UIColor {
    let r = CGFloat.random(in: 0 ... 255) / 255.0
    let g = CGFloat.random(in: 0 ... 255) / 255.0
    let b = CGFloat.random(in: 0 ... 255) / 255.0
    return UIColor(red: r, green: g, blue: b, alpha: 1.0)
}
