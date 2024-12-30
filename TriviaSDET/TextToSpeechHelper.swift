import AVFoundation

class TextToSpeechHelper: NSObject, AVSpeechSynthesizerDelegate {
    static let shared = TextToSpeechHelper()
        
        private let synthesizer = AVSpeechSynthesizer()
        private var isAudioSessionActive = false
        
        // Private initializer for singleton
        private override init() {
            super.init()
            synthesizer.delegate = self
            setupAudioSession()
        }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers, .mixWithOthers])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            isAudioSessionActive = true
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func speak(text: String) {
        // Ensure we're on the main thread
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Stop any ongoing speech
            if self.synthesizer.isSpeaking {
                self.synthesizer.stopSpeaking(at: .immediate)
            }
            
            // Reactivate audio session if needed
            if !self.isAudioSessionActive {
                self.setupAudioSession()
            }
            
            let utterance = AVSpeechUtterance(string: text)
            
            // Configure voice
            if let voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Samantha-premium") {
                utterance.voice = voice
            } else if let voice = AVSpeechSynthesisVoice(language: "en-US") {
                utterance.voice = voice
            }
            
            // Optimize speech settings for maximum volume and clarity
            utterance.rate = 0.4
            utterance.pitchMultiplier = 1.1
            utterance.volume = 1.0  // Maximum volume
            utterance.postUtteranceDelay = 0.5
            
            self.synthesizer.speak(utterance)
        }
    }
    
    func stopSpeaking() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if self.synthesizer.isSpeaking {
                self.synthesizer.stopSpeaking(at: .immediate)
            }
            
            self.deactivateAudioSession()
        }
    }
    
    private func deactivateAudioSession() {
        guard isAudioSessionActive else { return }
        
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            isAudioSessionActive = false
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
    }
    
    // AVSpeechSynthesizerDelegate methods
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        deactivateAudioSession()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        deactivateAudioSession()
    }
    
    deinit {
        stopSpeaking()
    }
}
