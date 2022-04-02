//
//  CustomUITextField.swift
//  drop-down-list-spike
//
//  Created by 瀬戸川将夫 on 2022/03/25.
//

import Foundation
import UIKit  //Don't forget this

class CustomUITextField: UITextField {
   override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        }
       
       if action == #selector(UIResponderStandardEditActions.copy(_:)) {
           return false
       }
       
       if action == #selector(UIResponderStandardEditActions.cut(_:)) {
           return false
       }
       
        return super.canPerformAction(action, withSender: sender)
   }
}
