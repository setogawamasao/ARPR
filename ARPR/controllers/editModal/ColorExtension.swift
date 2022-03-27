//
//  ColorExtension.swift
//  ARPR
//
//  Created by 瀬戸川将夫 on 2022/03/28.
//

import UIKit

extension EditModalViewController: UIColorPickerViewControllerDelegate {
    // 質問の色ボタン
    @IBAction func pickQuestionColor(_ sender: Any) {
        self.colorPickerMode = .question
        self.openColorPicker()
    }
    
    // 答えの色ボタン
    @IBAction func pickAnswerColor(_ sender: Any) {
        self.colorPickerMode = .answer
        self.openColorPicker()
    }
    
    // カラーピッカーを開く
    func openColorPicker(){
        let colorPicker = UIColorPickerViewController()
        if self.colorPickerMode == .question {
            if let questionColor = editedNode?.questionColor {
                colorPicker.selectedColor = questionColor
            }
        } else {
            if let answerColor = editedNode?.answerColor {
                colorPicker.selectedColor = answerColor
            }
        }
        colorPicker.delegate = self
        self.present(colorPicker, animated: true, completion: nil)
    }
    
    // 色を選択したときの処理
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        // print("選択した色: \(viewController.selectedColor)")
    }
        
    // カラーピッカーを閉じたときの処理
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        if self.colorPickerMode == .question{
            self.questionColorButton.backgroundColor = viewController.selectedColor
        } else {
            self.answerColorButton.backgroundColor = viewController.selectedColor
        }
    }
}
