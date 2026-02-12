import Foundation
import Combine
import UserNotifications
import OSLog

// MARK: - Constants
private enum Constants {
    static let settingsKey = "pomodoroSettings"
    static let timerInterval: TimeInterval = 1.0
}

// MARK: - Timer View Model
@MainActor
@Observable
final class TimerViewModel {
    private(set) var timerState: TimerState = .idle
    private(set) var currentSessionType: SessionType = .work
    private(set) var timeRemaining: Int = 25 * 60
    private(set) var timeString: String = "25:00"
    private(set) var completedSessions: Int = 0
    var isShowingSettings: Bool = false
    var settings: PomodoroSettings = .default
    var dailyStats: DailyStats = .zero
    var isPopoverVisible: Bool = false
    
    @ObservationIgnored
    private var timer: Timer?
    
    @ObservationIgnored
    private var lastTimeString: String = "25:00"
    
    @ObservationIgnored
    private let notificationService: NotificationServiceProtocol
    
    @ObservationIgnored
    private let soundService: SoundServiceProtocol
    
    @ObservationIgnored
    private let dailyStatsManager: DailyStatsManager
    
    @ObservationIgnored
    private let logger = Logger(subsystem: "com.justpomodoro", category: "TimerViewModel")
    
    init(
        notificationService: NotificationServiceProtocol = NotificationService(),
        soundService: SoundServiceProtocol = SoundService(),
        dailyStatsManager: DailyStatsManager = DailyStatsManager()
    ) {
        self.notificationService = notificationService
        self.soundService = soundService
        self.dailyStatsManager = dailyStatsManager
        loadSettings()
        resetTimer()
        requestNotificationPermissions()
        updateDailyStats()
    }
    
    nonisolated func startTimer() {
        Task { @MainActor in
            guard timerState != .running else { return }
            
            // Check if we need to reset stats (new day)
            dailyStatsManager.resetIfNeeded()
            updateDailyStats()
            
            timerState = .running
            timer = Timer.scheduledTimer(withTimeInterval: Constants.timerInterval, repeats: true) { [weak self] _ in
                guard let self else { return }
                Task { @MainActor in
                    self.tick()
                }
            }
        }
    }
    
    func pauseTimer() {
        guard timerState == .running else { return }
        timerState = .paused
        invalidateTimer()
    }
    
    func resetTimer() {
        timerState = .idle
        invalidateTimer()
        updateTimeRemaining()
    }
    
    func skipSession() {
        completeSession()
    }
    
    func updateSettings(_ newSettings: PomodoroSettings) {
        settings = newSettings
        if timerState == .idle {
            updateTimeRemaining()
        }
        saveSettings()
    }
    
    func resetDailyStats() {
        dailyStatsManager.resetStats()
        updateDailyStats()
    }
    
    private func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: Constants.settingsKey) {
            do {
                let decoded = try JSONDecoder().decode(PomodoroSettings.self, from: data)
                settings = decoded
                updateTimeRemaining()
            } catch {
                logger.error("Failed to decode settings: \(error.localizedDescription)")
            }
        }
    }
    
    private func saveSettings() {
        do {
            let encoded = try JSONEncoder().encode(settings)
            UserDefaults.standard.set(encoded, forKey: Constants.settingsKey)
        } catch {
            logger.error("Failed to encode settings: \(error.localizedDescription)")
        }
    }
    
    private func updateTimeRemaining() {
        let duration: Int
        switch currentSessionType {
        case .work:
            duration = settings.workDuration
        case .shortBreak:
            duration = settings.shortBreakDuration
        case .longBreak:
            duration = settings.longBreakDuration
        }
        timeRemaining = duration * 60
        updateTimeString()
    }
    
    func updateTimeString() {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        let newTimeString = String(format: "%02d:%02d", minutes, seconds)
        
        if isPopoverVisible || timeString != newTimeString {
            timeString = newTimeString
        }
    }
    
    private func updateDailyStats() {
        dailyStats = dailyStatsManager.stats
    }
    
    private func requestNotificationPermissions() {
        Task {
            await notificationService.requestAuthorization()
        }
    }
    
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func tick() {
        guard timeRemaining > 0 else {
            completeSession()
            return
        }
        timeRemaining -= 1
        updateTimeString()
    }
    
    private func completeSession() {
        invalidateTimer()
        
        trackCompletedSession()
        
        if settings.soundEnabled {
            soundService.playCompletionSound()
        }
        
        if settings.notificationsEnabled {
            Task {
                await notificationService.sendSessionCompleteNotification(
                    sessionType: currentSessionType,
                    soundEnabled: settings.soundEnabled
                )
            }
        }
        
        if currentSessionType == .work {
            completedSessions += 1
        }
        
        let previousSessionType = currentSessionType
        determineNextSession()
        
        timerState = .idle
        
        if shouldAutoStartForTransition(from: previousSessionType, to: currentSessionType) {
            startTimer()
        }
    }
    
    private func trackCompletedSession() {
        let duration: Int
        switch currentSessionType {
        case .work:
            duration = settings.workDuration
            dailyStatsManager.addWorkTime(minutes: duration)
        case .shortBreak:
            duration = settings.shortBreakDuration
            dailyStatsManager.addBreakTime(minutes: duration)
        case .longBreak:
            duration = settings.longBreakDuration
            dailyStatsManager.addBreakTime(minutes: duration)
        }
        updateDailyStats()
    }
    
    private func shouldAutoStartForTransition(from: SessionType, to: SessionType) -> Bool {
        switch to {
        case .work:
            return settings.autoStartWork
        case .shortBreak, .longBreak:
            return settings.autoStartBreaks
        }
    }
    
    func determineNextSession() {
        switch currentSessionType {
        case .work:
            if completedSessions % settings.sessionsBeforeLongBreak == 0 && completedSessions > 0 {
                currentSessionType = .longBreak
            } else {
                currentSessionType = .shortBreak
            }
        case .shortBreak, .longBreak:
            currentSessionType = .work
        }
        updateTimeRemaining()
    }
    
    var progress: Double {
        let totalTime: Int
        switch currentSessionType {
        case .work:
            totalTime = settings.workDuration * 60
        case .shortBreak:
            totalTime = settings.shortBreakDuration * 60
        case .longBreak:
            totalTime = settings.longBreakDuration * 60
        }
        guard totalTime > 0 else { return 0 }
        return Double(totalTime - timeRemaining) / Double(totalTime)
    }
    
    var sessionProgressText: String {
        let total = max(1, settings.sessionsBeforeLongBreak)
        let current = (completedSessions % total) + 1
        return "\(current) of \(total)"
    }
}
