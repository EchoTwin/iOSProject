//
//  TextToSpeechViewController.swift
//  EchoTwin
//
//  Created by Borislav Statev on 26.12.17.
//  Copyright © 2017 Echo Twin. All rights reserved.
//

import Foundation
import UIKit

class TextToSpeechViewController: UIViewController{
    
    @IBOutlet weak var chooseUsernameTextField: UITextField!
    @IBOutlet weak var readTextView: UITextView!
    @IBOutlet weak var readTextButton: UIButton!
    @IBOutlet weak var countSymbolsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readTextView.layer.borderColor = UIColor.magenta.cgColor
        readTextView.layer.borderWidth = 1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
