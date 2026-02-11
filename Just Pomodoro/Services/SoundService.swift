import AppKit
import AVFoundation

// MARK: - Protocol for testability
protocol SoundServiceProtocol {
    func playCompletionSound()
    func playStartSound()
    func playPauseSound()
}

// MARK: - Sound Service
final class SoundService: SoundServiceProtocol {
    func playCompletionSound() {
        NSSound.beep()
    }
    
    func playStartSound() {
        NSSound.beep()
    }
    
    func playPauseSound() {
        NSSound.beep()
    }
}
