import Foundation
import OSLog

// MARK: - Daily Stats
struct DailyStats: Codable, Sendable {
    var workTimeMinutes: Int
    var breakTimeMinutes: Int
    var lastTrackedDate: Date
    
    static var zero: DailyStats {
        DailyStats(workTimeMinutes: 0, breakTimeMinutes: 0, lastTrackedDate: Date())
    }
    
    var totalTimeMinutes: Int {
        workTimeMinutes + breakTimeMinutes
    }
    
    var formattedWorkTime: String {
        formatTime(minutes: workTimeMinutes)
    }
    
    var formattedBreakTime: String {
        formatTime(minutes: breakTimeMinutes)
    }
    
    var formattedTotalTime: String {
        formatTime(minutes: totalTimeMinutes)
    }
    
    private func formatTime(minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return "\(hours)h \(mins)m"
        } else {
            return "\(mins)m"
        }
    }
    
    func isFromToday() -> Bool {
        Calendar.current.isDateInToday(lastTrackedDate)
    }
}

// MARK: - Daily Stats Manager
@MainActor
@Observable
final class DailyStatsManager {
    private(set) var stats: DailyStats
    
    private let statsKey = "dailyStats"
    private let logger = Logger(subsystem: "com.justpomodoro", category: "DailyStatsManager")
    
    init() {
        if let data = UserDefaults.standard.data(forKey: statsKey) {
            do {
                let decoded = try JSONDecoder().decode(DailyStats.self, from: data)
                // Check if it's from today, if not reset
                if decoded.isFromToday() {
                    self.stats = decoded
                } else {
                    self.stats = .zero
                    saveStats()
                }
            } catch {
                logger.error("Failed to decode daily stats: \(error.localizedDescription)")
                self.stats = .zero
            }
        } else {
            self.stats = .zero
        }
    }
    
    func addWorkTime(minutes: Int) {
        stats.workTimeMinutes += minutes
        stats.lastTrackedDate = Date()
        saveStats()
    }
    
    func addBreakTime(minutes: Int) {
        stats.breakTimeMinutes += minutes
        stats.lastTrackedDate = Date()
        saveStats()
    }
    
    func resetIfNeeded() {
        if !stats.isFromToday() {
            stats = .zero
            saveStats()
        }
    }
    
    func resetStats() {
        stats = .zero
        saveStats()
    }
    
    private func saveStats() {
        do {
            let encoded = try JSONEncoder().encode(stats)
            UserDefaults.standard.set(encoded, forKey: statsKey)
        } catch {
            logger.error("Failed to encode daily stats: \(error.localizedDescription)")
        }
    }
}
