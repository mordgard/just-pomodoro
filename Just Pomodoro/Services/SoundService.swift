import AppKit
import AVFoundation
import OSLog

// MARK: - Sound Service Protocol
protocol SoundServiceProtocol: Sendable {
    func playCompletionSound()
    func playStartSound()
    func playPauseSound()
}

// MARK: - Sound Service
@preconcurrency
final class SoundService: SoundServiceProtocol, Sendable {
    private let logger = Logger(subsystem: "com.justpomodoro", category: "SoundService")
    
    func playCompletionSound() {
        NSSound.beep()
        logger.debug("Played completion sound")
    }
    
    func playStartSound() {
        NSSound.beep()
        logger.debug("Played start sound")
    }
    
    func playPauseSound() {
        NSSound.beep()
        logger.debug("Played pause sound")
    }
}
