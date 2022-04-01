//
//  ScaleExtension.swift
//  ARPR
//
//  Created by 瀬戸川将夫 on 2022/03/28.
//

extension EditModalViewController {
    // スケールを小さくする
    @IBAction func smallerScale(_ sender: Any) {
        let decrement = Float(0.001)
        guard let scaleText = textScale.text else { return }
        guard var scale = Float(scaleText) else {return}
        scale = scale - decrement
        if scale > 0 {
            textScale.text = String(format: "%.3f",scale)
        }
    }
    
    // スケールを大きくする
    @IBAction func biggerScale(_ sender: Any) {
        let increment = Float(0.001)
        guard let scaleText = textScale.text else { return }
        guard var scale = Float(scaleText) else {return}
        scale = scale + increment
        textScale.text = String(format: "%.3f",scale)
    }
}
