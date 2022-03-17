//
//  EditModalViewController.swift
//  ARPR
//
//  Created by 瀬戸川将夫 on 2022/03/17.
//

import UIKit
import SceneKit

protocol DataReturn {
    func returnData(qaNode:QaNode)
}

class EditModalViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var questionTextField: UITextField!
    @IBOutlet weak var answerTextField: UITextField!
    
    var initPostition: SCNVector3?
    
    var delegate: DataReturn?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionTextField.delegate = self
        answerTextField.delegate = self
    }
    
    @IBAction func save(_ sender: Any) {
        if let unwrapedQuestion = questionTextField.text,
           let unwrapedAnswer =  answerTextField.text,
           let unwrapedInitPosition = initPostition  {
            let qaNode = QaNode(question: unwrapedQuestion, answer: unwrapedAnswer, initPosition: unwrapedInitPosition)
            delegate?.returnData(qaNode: qaNode)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

}
