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
    
    var mode:ModalMode = ModalMode.new
    var editedNode: QaNode?
    
    var delegate: DataReturn?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionTextField.delegate = self
        answerTextField.delegate = self
        
        if mode == ModalMode.new{
            titleLabel.text = "新規作成"
        }
        else{
            titleLabel.text = "編集"
            questionTextField.text = editedNode?.question
            answerTextField.text = editedNode?.answer
        }
        
    }
    
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

}
