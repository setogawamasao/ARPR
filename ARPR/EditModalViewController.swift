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

class EditModalViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var questionTextField: UITextField!
    @IBOutlet weak var answerTextField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    var mode:ModalMode = ModalMode.new
    var editedNode: QaNode?
    
    var delegate: DataReturn?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionTextField.delegate = self
        answerTextField.delegate = self
        
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
            if let unwrapedNode = editedNode, let textGeometry = unwrapedNode.geometry as? SCNText {
                textGeometry.string = questionTextField.text
            }
            unwrapNode.question = questionTextField.text
            unwrapNode.answer = answerTextField.text
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

}
