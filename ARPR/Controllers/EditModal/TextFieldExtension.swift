//
//  TextFieldExtension.swift
//  ARPR
//
//  Created by 瀬戸川将夫 on 2022/03/28.
//

import UIKit

extension EditModalViewController: UITextFieldDelegate {
    // textfieldのreturn押下時
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
