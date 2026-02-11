import Foundation

enum TimerState: String, Codable {
    case idle
    case running
    case paused
}

enum SessionType: String, Codable, CaseIterable {
    case work = "Work"
    case shortBreak = "Short Break"
    case longBreak = "Long Break"
    
    var icon: String {
        switch self {
        case .work:
            return "figure.mind.and.body"
        case .shortBreak:
            return "cup.and.saucer.fill"
        case .longBreak:
            return "bed.double.fill"
        }
    }
    
    var color: String {
        switch self {
        case .work:
            return "workColor"
        case .shortBreak:
            return "shortBreakColor"
        case .longBreak:
            return "longBreakColor"
        }
    }
}

struct PomodoroSession: Identifiable, Codable {
    let id: UUID
    let type: SessionType
    let startTime: Date
    let endTime: Date
    let completed: Bool
    
    init(type: SessionType, startTime: Date, endTime: Date, completed: Bool) {
        self.id = UUID()
        self.type = type
        self.startTime = startTime
        self.endTime = endTime
        self.completed = completed
    }
}
