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
    @IBOutlet weak var soundTextField: CustomUITextField!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var questionColorButton: UIButton!
    @IBOutlet weak var answerColorButton: UIButton!
    @IBOutlet weak var textScale: UILabel!
    
    var mode:ModalMode = ModalMode.new
    var colorPickerMode:QAMode?
    var editedNode: QaNode?
    var delegate: DataReturn?
    var pickerView: UIPickerView = UIPickerView()
    var seManager = SEManager.sharedInstance
    let dropList: [ListItem] = [ListItem(key: "bass-drum.mp3", value: "バスドラム"),
                            ListItem(key: "dooon.mp3", value: "ドゥーン"),
                            ListItem(key: "explosion.mp3", value: "爆発"),
                            ListItem(key: "fracture.mp3", value: "グサ"),
                            ListItem(key: "jaaan.mp3", value: "ジャーン"),
                            ListItem(key: "plice.mp3", value: "プライス"),
                            ListItem(key: "reggae-hone.mp3", value: "レゲエホーン"),
                            ListItem(key: "scratch.mp3", value: "スクラッチ"),
                            ListItem(key: "shock.mp3", value: "ショック"),
                            ListItem(key: "gun.mp3",value: "銃声")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionTextField.delegate = self
        answerTextField.delegate = self
        soundTextField.delegate = self
        // ピッカー設定
        pickerView.delegate = self
        pickerView.dataSource = self
        
        // インプットビュー設定
        soundTextField.inputView = pickerView
        soundTextField.inputAccessoryView = self.generateToolBer()
        
        questionColorButton.backgroundColor = editedNode?.questionColor
        answerColorButton.backgroundColor = editedNode?.answerColor
        if let soundItem = dropList.first(where: { $0.key == editedNode?.soundName }) {
            soundTextField.text = soundItem.value
        }
        
        
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
            if let soundName = soundTextField.text {
                if let soundItem = dropList.first(where: { $0.value == soundName }) {
                    unwrapNode.soundName = soundItem.key
                }
            }
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
