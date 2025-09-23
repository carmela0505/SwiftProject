//
//  SpeechManager.swift
//  SWIFTAPP
//
//  Created by apprenant130 on 22/09/2025.
//

import Foundation
import AVFoundation

final class SpeechManager: ObservableObject {
    private let synth = AVSpeechSynthesizer()
    @Published var isMuted = true

    var language = "fr-CA"
    var rate: Float = AVSpeechUtteranceDefaultSpeechRate
    var pitch: Float = 0.5
    
    

    func speak(_ text: String) {
        guard !isMuted else { return }
        stop()
        let utt = AVSpeechUtterance(string: text)
        utt.voice = AVSpeechSynthesisVoice(language: language)
        utt.rate = rate
        utt.pitchMultiplier = pitch
        synth.speak(utt)
    }

    func speakQuestion(_ question: String, options: [String]) {
        let optionsJoined = options.enumerated().map { "Option \($0.offset + 1): \($0.element)." }.joined(separator: " ")
        speak("Question: \(question). \(optionsJoined)")
    }

    func speakResult(correct: Bool, correctText: String) {
        if correct {
            speak("Bonne réponse !")
        } else {
            speak("Mauvaise réponse. La bonne réponse est : \(correctText).")
        }
    }

    func stop() { synth.stopSpeaking(at: .immediate) }
}
