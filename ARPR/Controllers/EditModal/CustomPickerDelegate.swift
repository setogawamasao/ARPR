//
//  CustomPickerDelegate.swift
//  drop-down-list-spike
//
//  Created by 瀬戸川将夫 on 2022/03/25.
//

import UIKit

struct ListItem {
    var key: String
    var value: String
}

extension EditModalViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    // 決定バーの生成
    func generateToolBer() -> UIToolbar {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))

        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let playItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(play))
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))

        
        toolbar.setItems([playItem,spacelItem, doneItem], animated: true)
        return toolbar
    }
    
    // 決定ボタン押下
    @objc func play() {
        do{
            try seManager.playSound(soundName: dropList[pickerView.selectedRow(inComponent: 0)].key)

        } catch {
            print(error)
        }
    }
    
    // 決定ボタン押下
    @objc func done() {
        soundTextField.endEditing(true)
        soundTextField.text = dropList[pickerView.selectedRow(inComponent: 0)].value
    }
    
    // ドラムロールの列数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // ドラムロールの行数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dropList.count
    }
    
    // ドラムロールの各タイトル
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dropList.map {$0.value}[row]
    }
    
    // ドラムロール選択時
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("select")
        //self.textField.text = list[row]
    }
}
