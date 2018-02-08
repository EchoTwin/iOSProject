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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readTextView.layer.borderColor = UIColor.magenta.cgColor
        readTextView.layer.borderWidth = 1
        setCountSymbolsLabelText(textView: readTextView)
        readTextView.delegate = self
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
