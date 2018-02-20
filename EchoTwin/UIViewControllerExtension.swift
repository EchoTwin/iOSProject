//
//  EchoTwin
//
//  Created by Borislav Statev on 12.02.18.
//  Copyright © 2018 Echo Twin. All rights reserved.
//

import UIKit

extension UIViewController {
    func setDoneOnKeyboard(responder:UIResponder) {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.dismissKeyboard))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        if let textField = responder as? UITextField
        {
            textField.inputAccessoryView = keyboardToolbar
        }
        else if let textView = responder as? UITextView
        {
            textView.inputAccessoryView = keyboardToolbar
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
