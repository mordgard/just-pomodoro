import Foundation
import OSLog

// MARK: - Pomodoro Settings
struct PomodoroSettings: Codable, Sendable {
    var workDuration: Int // in minutes
    var shortBreakDuration: Int // in minutes
    var longBreakDuration: Int // in minutes
    var sessionsBeforeLongBreak: Int
    var autoStartBreaks: Bool
    var autoStartWork: Bool
    var soundEnabled: Bool
    var notificationsEnabled: Bool
    var showTimerInMenuBar: Bool
    
    static let `default` = PomodoroSettings(
        workDuration: 25,
        shortBreakDuration: 5,
        longBreakDuration: 15,
        sessionsBeforeLongBreak: 4,
        autoStartBreaks: false,
        autoStartWork: false,
        soundEnabled: true,
        notificationsEnabled: true,
        showTimerInMenuBar: true
    )
    
    static let minWorkDuration = 1
    static let maxWorkDuration = 60
    static let minBreakDuration = 1
    static let maxShortBreakDuration = 15
    static let maxLongBreakDuration = 30
    static let minSessionsBeforeLongBreak = 2
    static let maxSessionsBeforeLongBreak = 8
}

// MARK: - Settings Store
@Observable
final class SettingsStore {
    var settings: PomodoroSettings {
        didSet {
            saveSettings()
        }
    }
    
    private let settingsKey = "pomodoroSettings"
    private let logger = Logger(subsystem: "com.justpomodoro", category: "SettingsStore")
    
    init() {
        if let data = UserDefaults.standard.data(forKey: settingsKey) {
            do {
                let decoded = try JSONDecoder().decode(PomodoroSettings.self, from: data)
                self.settings = decoded
            } catch {
                logger.error("Failed to decode settings: \(error.localizedDescription)")
                self.settings = .default
            }
        } else {
            self.settings = .default
        }
    }
    
    private func saveSettings() {
        do {
            let encoded = try JSONEncoder().encode(settings)
            UserDefaults.standard.set(encoded, forKey: settingsKey)
        } catch {
            logger.error("Failed to encode settings: \(error.localizedDescription)")
        }
    }
    
    func resetToDefaults() {
        settings = .default
    }
}
