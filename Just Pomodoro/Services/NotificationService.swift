import UserNotifications

// MARK: - Protocol for testability
protocol NotificationServiceProtocol {
    func requestAuthorization()
    func sendSessionCompleteNotification(sessionType: SessionType, soundEnabled: Bool)
}

// MARK: - Notification Service
final class NotificationService: NotificationServiceProtocol {
    private var isAvailable: Bool {
        // Check if we're running in a proper app bundle
        Bundle.main.bundleIdentifier != nil
    }
    
    func requestAuthorization() {
        guard isAvailable else {
            print("Notifications not available - not running in app bundle")
            return
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error)")
            }
        }
    }
    
    func sendSessionCompleteNotification(sessionType: SessionType, soundEnabled: Bool) {
        guard isAvailable else { return }
        
        let content = UNMutableNotificationContent()
        
        switch sessionType {
        case .work:
            content.title = "Work session complete!"
            content.body = "Time to take a break."
        case .shortBreak:
            content.title = "Break is over!"
            content.body = "Ready to get back to work?"
        case .longBreak:
            content.title = "Long break complete!"
            content.body = "You're refreshed and ready to focus."
        }
        
        // Only add sound to notification if sound is enabled
        if soundEnabled {
            content.sound = .default
        }
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
}
