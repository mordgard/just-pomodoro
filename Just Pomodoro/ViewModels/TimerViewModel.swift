import Foundation
import Combine
import UserNotifications

// MARK: - Constants
private enum Constants {
    static let settingsKey = "pomodoroSettings"
    static let timerInterval: TimeInterval = 1.0
}

// MARK: - Timer View Model
@MainActor
final class TimerViewModel: ObservableObject {
    @Published private(set) var timerState: TimerState = .idle
    @Published private(set) var currentSessionType: SessionType = .work
    @Published private(set) var timeRemaining: Int = 25 * 60
    @Published private(set) var timeString: String = "25:00"
    @Published private(set) var completedSessions: Int = 0
    @Published var isShowingSettings: Bool = false
    @Published var settings: PomodoroSettings = .default
    @Published var dailyStats: DailyStats = .zero
    
    private var timer: Timer?
    private let notificationService: NotificationServiceProtocol
    private let soundService: SoundServiceProtocol
    private let dailyStatsManager: DailyStatsManager
    
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
    
    deinit {
        // Timer must be invalidated on the main thread
        // Since deinit can't be async, we schedule it on main queue
        if let timer = timer {
            DispatchQueue.main.async {
                timer.invalidate()
            }
        }
    }
}

// MARK: - Public Methods
extension TimerViewModel {
    func startTimer() {
        guard timerState != .running else { return }
        
        // Check if we need to reset stats (new day)
        dailyStatsManager.resetIfNeeded()
        updateDailyStats()
        
        timerState = .running
        timer = Timer.scheduledTimer(withTimeInterval: Constants.timerInterval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.tick()
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
    
}

// MARK: - Private Methods
private extension TimerViewModel {
    func loadSettings() {
        guard let data = UserDefaults.standard.data(forKey: Constants.settingsKey),
              let decoded = try? JSONDecoder().decode(PomodoroSettings.self, from: data) else {
            return
        }
        settings = decoded
        updateTimeRemaining()
    }
    
    func saveSettings() {
        guard let encoded = try? JSONEncoder().encode(settings) else {
            print("Failed to encode settings")
            return
        }
        UserDefaults.standard.set(encoded, forKey: Constants.settingsKey)
    }
    
    func updateTimeRemaining() {
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
        timeString = String(format: "%02d:%02d", minutes, seconds)
    }
    
    func updateDailyStats() {
        dailyStats = dailyStatsManager.stats
    }
    
    func requestNotificationPermissions() {
        notificationService.requestAuthorization()
    }
    
    func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func tick() {
        guard timeRemaining > 0 else {
            completeSession()
            return
        }
        timeRemaining -= 1
        updateTimeString()
    }
    
    func completeSession() {
        invalidateTimer()
        
        // Track the completed session time
        trackCompletedSession()
        
        // Play sound if enabled
        if settings.soundEnabled {
            soundService.playCompletionSound()
        }
        
        // Send notification if enabled
        if settings.notificationsEnabled {
            notificationService.sendSessionCompleteNotification(sessionType: currentSessionType, soundEnabled: settings.soundEnabled)
        }
        
        // Update session tracking
        if currentSessionType == .work {
            completedSessions += 1
        }
        
        // Determine next session type
        let previousSessionType = currentSessionType
        determineNextSession()
        
        // Set state to idle BEFORE checking auto-start
        // This allows startTimer() to actually start
        timerState = .idle
        
        // Auto-start if configured based on what we're transitioning TO
        if shouldAutoStartForTransition(from: previousSessionType, to: currentSessionType) {
            startTimer()
        }
    }
    
    func trackCompletedSession() {
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
    
    func shouldAutoStartForTransition(from: SessionType, to: SessionType) -> Bool {
        // When transitioning TO a break session, check autoStartBreaks
        // When transitioning TO a work session, check autoStartWork
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
}

// MARK: - Computed Properties
extension TimerViewModel {
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
