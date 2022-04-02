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

class EditModalViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var questionTextField: UITextField!
    @IBOutlet weak var answerTextField: UITextField!
    @IBOutlet weak var soundTextField: UITextField!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var questionColorButton: UIButton!
    @IBOutlet weak var answerColorButton: UIButton!
    @IBOutlet weak var textScale: UILabel!
    
    var mode:ModalMode = ModalMode.new
    var colorPickerMode:QAMode?
    var editedNode: QaNode?
    var delegate: DataReturn?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionTextField.delegate = self
        answerTextField.delegate = self
        soundTextField.delegate = self
        
        questionColorButton.backgroundColor = editedNode?.questionColor
        answerColorButton.backgroundColor = editedNode?.answerColor
        
        if mode == ModalMode.new{
            titleLabel.text = "新規作成"
            deleteButton.isHidden = true
            
            if let node = editedNode {
                textScale.text = String(node.textScale)
            }
            
            // ↓↓ リリース時は消す ↓↓
            questionTextField.text = "あいう"
            answerTextField.text = "えお"
            // ↑↑ リリース時は消す ↑↑
        }
        else{
            titleLabel.text = "編集"
            questionTextField.text = editedNode?.question
            answerTextField.text = editedNode?.answer
            
            if let scale = editedNode?.textNode?.scale.x {
                textScale.text = String(scale)
            }
        }
    }
    
    // 保存ボタン
    @IBAction func save(_ sender: Any) {
        if let unwrapNode = editedNode{
            if let unwrapedNode = editedNode,
               let textNode = unwrapedNode.textNode,
               let textGeometry = textNode.geometry as? SCNText {
                // calor and text
                if unwrapNode.isAnswered {
                    textGeometry.firstMaterial?.diffuse.contents = answerColorButton.backgroundColor
                    textGeometry.string = answerTextField.text
                } else{
                    textGeometry.firstMaterial?.diffuse.contents = questionColorButton.backgroundColor
                    textGeometry.string = questionTextField.text
                }
                // scale
                if let scaleText = textScale.text, let scale = Float(scaleText) {
                        textNode.scale.x = scale
                        textNode.scale.y = scale
                }
            }
            unwrapNode.questionColor = questionColorButton.backgroundColor!
            unwrapNode.answerColor = answerColorButton.backgroundColor!
            unwrapNode.question = questionTextField.text
            unwrapNode.answer = answerTextField.text
            unwrapNode.centerPivot()
            
            if mode == ModalMode.new {
                if let scaleText = textScale.text, let scale = Float(scaleText) {
                    unwrapNode.textScale = scale
                }
                delegate?.returnData(qaNode: unwrapNode, mode: ModalMode.new)
            } else {
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
}
