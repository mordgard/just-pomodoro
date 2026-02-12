import UserNotifications
import OSLog

// MARK: - Notification Service Protocol
protocol NotificationServiceProtocol: Sendable {
    func requestAuthorization() async
    func sendSessionCompleteNotification(sessionType: SessionType, soundEnabled: Bool) async
}

// MARK: - Notification Service
@preconcurrency
final class NotificationService: NotificationServiceProtocol, Sendable {
    private let logger = Logger(subsystem: "com.justpomodoro", category: "NotificationService")
    
    private var isAvailable: Bool {
        // Check if we're running in a proper app bundle
        Bundle.main.bundleIdentifier != nil
    }
    
    func requestAuthorization() async {
        guard isAvailable else {
            logger.warning("Notifications not available - not running in app bundle")
            return
        }
        
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound])
            if granted {
                logger.info("Notification authorization granted")
            } else {
                logger.warning("Notification authorization denied")
            }
        } catch {
            logger.error("Notification authorization error: \(error.localizedDescription)")
        }
    }
    
    func sendSessionCompleteNotification(sessionType: SessionType, soundEnabled: Bool) async {
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
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            logger.error("Failed to schedule notification: \(error.localizedDescription)")
        }
    }
}
