//
//  SpeechViewController.swift
//  VoiceDemo
//
//  Created by linkage on 2019/2/15.
//  Copyright © 2019年 yuanjian. All rights reserved.
//

import UIKit
import Speech
import AVFoundation

class SpeechViewController: UIViewController {

    @IBOutlet weak var textLabel: UITextView!
    @IBOutlet weak var recordBtn: UIButton!
    fileprivate var recordRequest: SFSpeechAudioBufferRecognitionRequest?
    fileprivate var recordTask: SFSpeechRecognitionTask?
    fileprivate let audioEngine = AVAudioEngine()
    fileprivate lazy var recognizer: SFSpeechRecognizer = {//
        let recognize = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))
        recognize?.delegate = self
        return recognize!
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSpeechRecordLimit()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopRecognize()
    }

    @IBAction func record(_ sender: UIButton) {
        let isStart = sender.currentTitle!.contains("開始")
        recordBtn.setTitle(isStart ? "録音の停止" : "録音を開始します", for: .normal)
        isStart ? startRecognize() : stopRecognize()
    }
}

//MARK: 記録認識
extension SpeechViewController{

    fileprivate func startRecognize(){
        //1. 現在のタスクを停止する
        stopRecognize()
        
        //2. オーディオセッションの作成
        let session = AVAudioSession.sharedInstance()
        do{
            try session.setCategory(AVAudioSession.Category.record, mode: AVAudioSession.Mode.measurement, options: AVAudioSession.CategoryOptions.duckOthers)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        }catch{
            print("Throws：\(error)")
        }
        
        //3. 認識要求の作成
        recordRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        // 認識の開始テキストの取得
        recordTask = recognizer.recognitionTask(with: recordRequest!, resultHandler: { (result, error) in
            if result != nil {
                var text = ""
                for trans in result!.transcriptions{
                    text += trans.formattedString
                }
                self.textLabel.text = text
                
                if result!.isFinal{
                    self.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    self.recordRequest = nil
                    self.recordTask = nil
                    self.recordBtn.isEnabled = true
                }
            }
        })
        let recordFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordFormat, block: { (buffer, time) in
            self.recordRequest?.append(buffer)
        })
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Throws：\(error)")
        }
    }
    
    // 停止识别
    fileprivate func stopRecognize(){
        if recordTask != nil{
            recordTask?.cancel()
            recordTask = nil
        }
        removeTask()
    }
    
    // 記録タスクの破棄
    fileprivate func removeTask(){
        self.audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        self.recordRequest = nil
        self.recordTask = nil
        self.recordBtn.isEnabled = true
    }
    
    // 音声認識のアクセス許可の認証
    fileprivate func addSpeechRecordLimit(){
        SFSpeechRecognizer.requestAuthorization { (state) in
            var isEnable = false
            switch state {
            case .authorized:
                isEnable = true
                print("許可された音声認識")
            case .notDetermined:
                isEnable = false
                print("承認された音声認識なし")
            case .denied:
                isEnable = false
                print("ユーザーが音声認識へのアクセスを拒否しました")
            case .restricted:
                isEnable = false
                print("このデバイスでは音声認識を実行できません")
            }
            DispatchQueue.main.async {
                self.recordBtn.isEnabled = isEnable
                if !isEnable {
                    self.recordBtn.backgroundColor = UIColor.lightGray
                }
                
            }
        }
    }
}

//MARK:
extension SpeechViewController: SFSpeechRecognizerDelegate{
    // 音声認識エンジンの可用性を監視する
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        recordBtn.isEnabled = available
    }
}
