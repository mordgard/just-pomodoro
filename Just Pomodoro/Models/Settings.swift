import Foundation

struct PomodoroSettings: Codable {
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

class SettingsStore: ObservableObject {
    @Published var settings: PomodoroSettings {
        didSet {
            saveSettings()
        }
    }
    
    private let settingsKey = "pomodoroSettings"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(PomodoroSettings.self, from: data) {
            self.settings = decoded
        } else {
            self.settings = .default
        }
    }
    
    private func saveSettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: settingsKey)
        }
    }
    
    func resetToDefaults() {
        settings = .default
    }
}
