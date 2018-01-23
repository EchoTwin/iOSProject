//
//  ViewController.swift
//  EchoTwin
//
//  Created by Borislav Statev on 10/31/17.
//  Copyright © 2017 Echo Twin. All rights reserved.
//


import AVFoundation
import UIKit
import Firebase

class RecordViewController: UIViewController,  AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    @IBOutlet weak var recordButton: UIButton!
    private var recordingSession: AVAudioSession!
    @IBOutlet weak var playButton: UIButton!
    private var audioRecorder: AVAudioRecorder!
    private var audioPlayer: AVAudioPlayer?
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var recordingTimerLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernamePictureButton: UIButton!
    
    var timer:Timer = Timer()
    var seconds = 0;
    var storageRef: StorageReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storageRef = Storage.storage().reference()
        recordButton.layer.cornerRadius = recordButton.bounds.size.width * 0.5;
        playButton.layer.cornerRadius = playButton.bounds.size.width * 0.5;
        setDoneOnKeyboard(textField:usernameTextField)
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.recordButton.isHidden = false;
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
        navigationController?.navigationBar.topItem?.title = "Back";
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.topItem?.title = "EchoTwin";
    }
    
    @IBAction func recordButton_TouchUpInside(_ sender: UIButton) {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    @IBAction func playButton_TouchUpInside(_ sender: UIButton) {
        if (!sender.isSelected){
            startPlaying()
        }
        else{
            stopPlaying()
        }
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func uploadButton_TouchUpInside(_ sender: UIButton) {
        uploadAudioToFirebase()
    }
    
    @IBAction func userPictureButton_TouchUpInside(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    fileprivate func getAudioFileUrl() -> URL {
        return getDocumentsDirectory().appendingPathComponent("recording.m4a")
    }
    
    func uploadAudioToFirebase(){
        // File located on disk
        let localFile = getAudioFileUrl()
        
        // Create a reference to the file you want to upload
        let voiceRef = storageRef.child("Voices/ios.m4a")
        
        // Upload the file to the path "images/rivers.jpg"
        voiceRef.putFile(from: localFile)
    }
    
    func startRecording() {
        let audioFilename = getAudioFileUrl()
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            recordButton.isSelected = true;
            runRecordingTimer()
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        stopTimer()
        recordButton.isSelected = false;
        playButton.isEnabled = success;
        uploadButton.isEnabled = success;
    }
    
    func startPlaying(){
        let audioFilename = getAudioFileUrl()
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try! AVAudioSession.sharedInstance().setActive(true)
        
        try! audioPlayer = AVAudioPlayer(contentsOf: audioFilename)
        audioPlayer!.delegate = self
        audioPlayer!.prepareToPlay()
        audioPlayer!.play();
    }
    
    func stopPlaying(){
        audioPlayer!.stop();
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        playButton.isSelected = false;
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func runRecordingTimer()
    {
        runTimer(timerLabel: recordingTimerLabel, selector: #selector(self.updateRecordingTimer))
    }
    
    func runTimer(timerLabel:UILabel, selector aSelector: Selector) {
        resetTimer(timerLabel: timerLabel)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: aSelector, userInfo: nil, repeats: true)
    }
    
    func stopTimer(){
        timer.invalidate()
    }
    
    func timeString(time:TimeInterval) -> String {
        let minutes:Int = Int(time) / 60 % 60
        let seconds:Int = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
    
    @objc func updateRecordingTimer() {
        updateTimer(timerLabel: recordingTimerLabel)
    }
    
    func updateTimer(timerLabel:UILabel) {
        seconds += 1
        timerLabel.text = timeString(time: TimeInterval(seconds))
    }
    
    func resetTimer(timerLabel:UILabel) {
        seconds = 0
        timerLabel.text = timeString(time: TimeInterval(seconds))
    }
    
    func setDoneOnKeyboard(textField:UITextField) {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.dismissKeyboard))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        textField.inputAccessoryView = keyboardToolbar
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension RecordViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            usernamePictureButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
            usernamePictureButton.setImage(image, for: UIControlState.normal)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
