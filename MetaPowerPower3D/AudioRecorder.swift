//
//  AudioRecorder.swift
//  MetaPowerPower3D
//
//  Created by 石勇 on 2024/4/21.
//

import Foundation
import SwiftUI
import AVFoundation
import Combine


class AudioRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate {
    let audioRecorder: AVAudioRecorder
    @Published var isRecording = false
    let audioBufferPublisher = PassthroughSubject<Data, Never>()
    
    override init() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try audioSession.setActive(true)
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            let docsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let audioURL = docsDirectory.appendingPathComponent("recorded_voice.m4a")
            
            audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
        } catch {
            print("Error setting up audio session or recorder: \(error.localizedDescription)")
            audioRecorder = AVAudioRecorder()
        }
        
        super.init()
    }
    
    func startRecording() {
        if !isRecording {
            audioRecorder.record()
            isRecording = true
        }
    }
    
    func stopRecording() {
        if isRecording {
            audioRecorder.stop()
            isRecording = false
        }
    }
        
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("Recording finished successfully")
            sendAudioBuffer()
        } else {
            print("Recording finished with error")
        }
    }
    
    func sendAudioBuffer() {
        let audioFile = AVAudioFile(forReading: audioRecorder.url)
        
        guard let audioFile = audioFile, let format = audioFile.processingFormat else {
            print("Failed to create AVAudioFile or get processing format")
            return
        }
        
        let frameCount = UInt32(audioFile.length)
        let audioBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)
        
        do {
            try audioFile.read(into: audioBuffer!)
            let data = audioBuffer!.toData()
            audioBufferPublisher.send(data)
        } catch {
            print("Error reading audio file: \(error.localizedDescription)")
        }
    }
}

extension AVAudioPCMBuffer {
    func toData() -> Data {
        let channelCount = Int(format.channelCount)
        let frameLength = Int(frameLength)
        let buffer = UnsafeBufferPointer<Int16>(
            start: int16ChannelData?.assumingMemoryBound(to: Int16.self),
            count: frameLength * channelCount
        )
        
        return Data(buffer)
    }
}

