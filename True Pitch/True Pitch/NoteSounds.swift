//
//  NoteSounds.swift
//  True Pitch
//
//  Created by A on 7/31/25.
//

import Foundation
import AVFoundation
import SwiftData

class NoteSounds {
    var audioPlayerNode = AVAudioPlayerNode()
    var audioPitchTime = AVAudioUnitTimePitch()
    var audioFile: AVAudioFile
    var audioBuffer: AVAudioBuffer
    var name: String
    var engine: AVAudioEngine
    var isPlaying: Bool = false
    
    init?(forSound sound:String, withEngine avEngine:AVAudioEngine) {
        do {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Error for settin up AVAudioSession: \(error)")
            }
            audioPlayerNode.stop()
            name = sound
            engine = avEngine
            let soundFile = NSURL(fileURLWithPath: Bundle.main.path(forResource: sound, ofType: "wav")!) as URL
            try audioFile = AVAudioFile(forReading: soundFile)
            if let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(audioFile.length)) {
                audioBuffer = buffer
                try audioFile.read(into: audioBuffer as! AVAudioPCMBuffer)
                engine.attach(audioPlayerNode)
                engine.attach(audioPitchTime)
                engine.connect(audioPlayerNode, to: audioPitchTime, format: audioBuffer.format)
                engine.connect(audioPitchTime, to: engine.mainMixerNode, format: audioBuffer.format)
                
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    func play(pitch: Float) {
        if !engine.isRunning {
            engine.reset()
            try! engine.start()
        }
        audioPlayerNode.play()
        audioPitchTime.pitch = pitch
        audioPlayerNode.scheduleBuffer(audioBuffer as! AVAudioPCMBuffer) {
            self.isPlaying = false
        }
        isPlaying = true
    }
}

class Sounds {
    
    private let engine = AVAudioEngine()
    
    private let squareSound: [String] = ["square_c3", "square_c4"]
    private let pianoSound: [String] = [
        "c3", "cs3", "d3", "ds3", "e3", "f3", "fs3", "g3", "gs3", "a3", "as3", "b3",
        "c4", "cs4", "d4", "ds4", "e4", "f4", "fs4", "g4", "gs4", "a4", "as4", "b4",
        "c5", "cs5", "d5", "ds5", "e5", "f5", "fs5", "g5", "gs5", "a5", "as5", "b5",
    ]
    
    func play(soundType: Int, pitch: Int) {
        if let sound = NoteSounds(forSound: getSample(sound: soundType, pitch: pitch), withEngine: engine) {
            if soundType == 0 { sound.play(pitch: (Float(pitch) * 100)) }
            else { sound.play(pitch: 0) }
        }
    }
    
    private func getSample(sound: Int, pitch: Int) -> String {
        print(pitch)
        if sound == 0 {
            return pitch >= 12 ? squareSound[0] : squareSound[1]
        } else {
            return pianoSound[pitch + 12]
        }
    }
}
