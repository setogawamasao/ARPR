//
//  EditModalViewController.swift
//  ARPR
//
//  Created by 瀬戸川将夫 on 2022/03/17.
//

import UIKit
import SceneKit

protocol DataReturn {
    func returnData(qaNode:QaNode,mode:ModalMode)
}

enum ModalMode {
    case new
    case update
}

enum QAMode {
    case question
    case answer
}

class EditModalViewController: UIViewController, UITextFieldDelegate, UIColorPickerViewControllerDelegate {

    @IBOutlet weak var questionTextField: UITextField!
    @IBOutlet weak var answerTextField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var questionColorButton: UIButton!
    @IBOutlet weak var answerColorButton: UIButton!
    
    var mode:ModalMode = ModalMode.new
    var colorPickerMode:QAMode?
    var editedNode: QaNode?
    var delegate: DataReturn?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionTextField.delegate = self
        answerTextField.delegate = self
        
        questionColorButton.backgroundColor = editedNode?.questionColor
        answerColorButton.backgroundColor = editedNode?.answerColor
        
        if mode == ModalMode.new{
            titleLabel.text = "新規作成"
            deleteButton.isHidden = true
            
            // ↓↓ リリース時は消す ↓↓
            questionTextField.text = "あいう"
            answerTextField.text = "えお"
            // ↑↑ リリース時は消す ↑↑
        }
        else{
            titleLabel.text = "編集"
            questionTextField.text = editedNode?.question
            answerTextField.text = editedNode?.answer
        }
    }
    
    // 保存ボタン
    @IBAction func save(_ sender: Any) {
        if let unwrapNode = editedNode{
            if let unwrapedNode = editedNode,
               let textNode = unwrapedNode.textNode,
               let textGeometry = textNode.geometry as? SCNText {
                if unwrapNode.isAnswered {
                    textGeometry.firstMaterial?.diffuse.contents = answerColorButton.backgroundColor
                    textGeometry.string = answerTextField.text
                } else{
                    textGeometry.firstMaterial?.diffuse.contents = questionColorButton.backgroundColor
                    textGeometry.string = questionTextField.text
                }
            }
            unwrapNode.question = questionTextField.text
            unwrapNode.answer = answerTextField.text
            unwrapNode.centerPivot()
            unwrapNode.questionColor = questionColorButton.backgroundColor!
            unwrapNode.answerColor = answerColorButton.backgroundColor!
            
            if mode == ModalMode.new {
                delegate?.returnData(qaNode: unwrapNode, mode: ModalMode.new)
            }else{
                delegate?.returnData(qaNode: unwrapNode, mode: ModalMode.update)
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
   // 削除ボタン
    @IBAction func deleteQa(_ sender: Any) {
        guard let editedNode = editedNode else { return }
        editedNode.removeFromParentNode()
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    @IBAction func pickQuestionColor(_ sender: Any) {
        self.colorPickerMode = .question
        self.openColorPicker()
    }
    
    @IBAction func pickAnswerColor(_ sender: Any) {
        self.colorPickerMode = .answer
        self.openColorPicker()
    }
    
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
