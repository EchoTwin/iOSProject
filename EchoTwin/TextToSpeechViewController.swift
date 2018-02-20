//
//  TextToSpeechViewController.swift
//  EchoTwin
//
//  Created by Borislav Statev on 26.12.17.
//  Copyright © 2017 Echo Twin. All rights reserved.
//

import Foundation
import UIKit

class TextToSpeechViewController: UIViewController, UITextViewDelegate{
    let maxNumberOfSymbols = 500;
    
    @IBOutlet weak var chooseUsernameTextField: UITextField!
    @IBOutlet weak var readTextView: UITextView!
    @IBOutlet weak var readTextButton: UIButton!
    @IBOutlet weak var countSymbolsLabel: UILabel!
    var pickerData: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readTextView.layer.borderColor = UIColor.magenta.cgColor
        readTextView.layer.borderWidth = 1
        setDoneOnKeyboard(responder:readTextView)
        setDoneOnKeyboard(responder:chooseUsernameTextField)
        setCountSymbolsLabelText(textView: readTextView)
        readTextView.delegate = self
        
        pickerData = ["User 1", "User 2", "User 3", "User 4", "User 5", "User 6"]
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        chooseUsernameTextField.inputView = pickerView
        chooseUsernameTextField.text = pickerData[0]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        setCountSymbolsLabelText(textView: textView)
    }
    
    func setCountSymbolsLabelText(textView: UITextView){
        countSymbolsLabel.text = "\(textView.text.count)/\(maxNumberOfSymbols)";
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < maxNumberOfSymbols + 1
    }
}

extension TextToSpeechViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        chooseUsernameTextField.text = pickerData[row]
    }
}
