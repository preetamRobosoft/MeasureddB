//
//  ViewController.swift
//  MeasuredB
//
//  Created by Preetam G on 24/02/23.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    var audioPlayer: AVAudioPlayer!
    var audioSession: AVAudioSession!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpAudioCapture()
    }
    
    private func setUpAudioCapture() {
        let audioURL = Bundle.main.url(forResource: "audio", withExtension: "mp3")!
        
        let recordingSession = AVAudioSession.sharedInstance()
        
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            try recordingSession.setCategory(.playAndRecord)
            try recordingSession.setActive(true)
            try recordingSession.setMode(.measurement)
            AVAudioSession.CategoryOptions.mixWithOthers
            recordingSession.requestRecordPermission({ result in
                guard result else { return }
            })
            audioPlayer.play()
            captureAudio()
             
        } catch {
            print("ERROR: Failed to set up recording session.")
        }
    }
    
    private func captureAudio() {
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentPath.appendingPathComponent("record.caf")
        let settings:[String : Any] =
            [
                AVFormatIDKey :kAudioFormatAppleIMA4 as AnyObject,
                AVSampleRateKey:44100,
                AVNumberOfChannelsKey:1,
                AVLinearPCMBitDepthKey:32 ,
                AVLinearPCMIsBigEndianKey:false,
                AVLinearPCMIsFloatKey:false,
                AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
            ]
        
        do {
            
            let audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            audioRecorder.isMeteringEnabled = true
            
            
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                audioRecorder.updateMeters()
                let db = audioRecorder.averagePower(forChannel: 0)
                let peakdb = audioRecorder.peakPower(forChannel: 0)
                //                    let pTd = vDSP.powerToDecibels([db], zeroReference: -80)
                
                
                print("Avg(needed)",abs(db))
            }
        } catch {
            print("ERROR: Failed to start recording process.")
        }
    }
    
    
}

