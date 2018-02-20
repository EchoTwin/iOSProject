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
    
    let recordingSecondsLimit = 60
    
    var timer:Timer = Timer()
    var currentRecordingSeconds = 60
    var storageRef: StorageReference!
    var imageUrl:URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetTimer(timerLabel: recordingTimerLabel)
        storageRef = Storage.storage().reference()
        recordButton.layer.cornerRadius = recordButton.bounds.size.width * 0.5;
        playButton.layer.cornerRadius = playButton.bounds.size.width * 0.5;
        setDoneOnKeyboard(responder:usernameTextField)
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
    
    @IBAction func userPictureButton_TouchUpInside(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func uploadButton_TouchUpInside(_ sender: UIButton) {
        if (usernameTextField.text?.isEmpty == false &&
            imageUrl != nil)
        {
            let mRef = Database.database().reference()
            let audioFile = uploadAudioToFirebase()
            let imageFile = uploadImageToFirebase()
            let username = usernameTextField.text
            
            let key = mRef.childByAutoId().key
            let voiceRecord = ["pictureFileURL":imageFile,
                 "userName": username,
                 "voiceFileURL": audioFile
            ]
            
            mRef.child(key).setValue(voiceRecord)
        }
        else{
            showMomentMessage(text: "Username and picture are required!")
        }
    }
    
    fileprivate func getAudioFileUrl() -> URL {
        return getDocumentsDirectory().appendingPathComponent("recording.m4a")
    }
    
    func uploadAudioToFirebase() -> String{
        // File located on disk
        let localFile = getAudioFileUrl()
        let fileName = NSInteger(NSDate().timeIntervalSince1970 * 1000);
        let saveToFile = "\(fileName).m4a"
        // Create a reference to the file you want to upload
        let voiceRef = storageRef.child("Voices/\(saveToFile)")
        let uploadTask = voiceRef.putFile(from: localFile, metadata: nil)
        showLoading(uploadTask: uploadTask, fileType: "Voice")
        return saveToFile
    }
    
    func uploadImageToFirebase() -> String?{
        // File located on disk
        if let localFile = imageUrl{
            let fileName = NSInteger(NSDate().timeIntervalSince1970 * 1000);
            let saveToFile = "\(fileName).\(localFile.pathExtension)"
            // Create a reference to the file you want to upload
            let avatarRef = storageRef.child("Avatars/\(saveToFile)")
            let uploadTask = avatarRef.putFile(from: localFile, metadata: nil)
            showLoading(uploadTask: uploadTask, fileType: "Avatar")
            return saveToFile
        }
        return nil
    }
    
    fileprivate func showMomentMessage(text:String) {
        let alert = UIAlertController(title: "", message: text, preferredStyle: .alert)
        self.present(alert, animated: true)
        
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when){
            // your code with delay
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    func showLoading(uploadTask: StorageUploadTask, fileType: String){
        var alert:UIAlertController? = nil
        uploadTask.observe(.resume) { _ in
            alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
            
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            loadingIndicator.startAnimating();
            
            alert!.view.addSubview(loadingIndicator)
            self.present(alert!, animated: true, completion: nil)
        }
        uploadTask.observe(.success) { _ in
            alert!.dismiss(animated: true, completion: nil)
            self.showMomentMessage(text:"\(fileType) file uploaded")
        }
        uploadTask.observe(.failure) { _ in
            alert!.dismiss(animated: true, completion: nil)
            self.showMomentMessage(text:"\(fileType) upload failed")
        }
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
        playButton.isHidden = !success;
        uploadButton.isHidden = !success;
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
        currentRecordingSeconds -= 1
        timerLabel.text = timeString(time: TimeInterval(currentRecordingSeconds))
        if (currentRecordingSeconds == 0){
            finishRecording(success: true)
        }
    }
    
    func resetTimer(timerLabel:UILabel) {
        currentRecordingSeconds = recordingSecondsLimit
        timerLabel.text = timeString(time: TimeInterval(currentRecordingSeconds))
    }
}

extension RecordViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            usernamePictureButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
            usernamePictureButton.setImage(image, for: UIControlState.normal)
            imageUrl = info["UIImagePickerControllerImageURL"] as? URL
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
