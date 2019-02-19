//
//  ViewController.swift
//  VoiceDemo
//
//  Created by linkage on 2019/2/15.
//  Copyright © 2019年 yuanjian. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    fileprivate let avSpeech = AVSpeechSynthesizer()
    @IBOutlet weak var willSpeek: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        avSpeech.delegate = self
    }
    
    @IBAction func jump(_ sender: UIButton) {
        self.performSegue(withIdentifier: "jump", sender: self)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancleSpeek()
    }

    @IBAction func translation(_ sender: UIButton) {
        let isStart = sender.currentTitle!.contains("開始")
        textView.resignFirstResponder()
        startButton.setTitle(isStart ? "再生のキャンセル" : "再生の開始", for: .normal)
        isStart ? startTranslattion() : cancleSpeek()
    }
    
    @IBAction func pauseOrContinue(_ sender: UIButton) {
        let isPause = sender.currentTitle!.contains("停止")
        pauseButton.setTitle(isPause ? "再生を続ける" : "再生の一時停止", for: .normal)
        isPause ? pauseTranslation() : continueSpeek()
    }
    
    //戻る実装
    @IBAction func myUnwindAction(segue: UIStoryboardSegue) {
        
        
    }
}

extension ViewController{

    fileprivate func startTranslattion(){
        //1. 合成する必要があるサウンドタイプを作成する
        let voice = AVSpeechSynthesisVoice(language: "ja-JP")
        
        //2. コンポジット音声クラスの作成
        let utterance = AVSpeechUtterance(string: textView.text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.voice = voice
        utterance.volume = 1
        utterance.postUtteranceDelay = 0.1
        utterance.pitchMultiplier = 1
        //再生の開始
        avSpeech.speak(utterance)
    }
    
    //再生の一時停止
    fileprivate func pauseTranslation(){
        avSpeech.pauseSpeaking(at: .immediate)
    }
    
    //再生を続ける
    fileprivate func continueSpeek(){
        avSpeech.continueSpeaking()
    }
    
    //再生のキャンセル
    fileprivate func cancleSpeek(){
        avSpeech.stopSpeaking(at: .immediate)
    }
}

//MARK: AVSpeechSynthesizerDelegate
extension ViewController: AVSpeechSynthesizerDelegate{
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("再生の開始")
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        startButton.setTitle("再生の開始", for: .normal)
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        print("再生の一時停止")
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        print("再生を続ける")
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("再生のキャンセル")
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        print(characterRange.location, "-----", characterRange.length)
        let subStr = utterance.speechString.dropFirst(characterRange.location).description
        let rangeStr = subStr.dropLast(subStr.count - characterRange.length).description
        willSpeek.text = rangeStr
    }
}

