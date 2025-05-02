
import Foundation

enum RepeatOption: String, CaseIterable, Identifiable {
    case None = "None"
    case daily = "Daily"
    case weekends = "Weekends"
    case monthly = "Monthly"
    
    var id: String { self.rawValue }
}

enum ReminderOffset: String, CaseIterable, Identifiable {
    case none = "On time"
    case tenMinutes = "10 minutes early"
    case thirtyMinutes = "30 minutes early"
    case oneHour = "1 hour early"
    
    var id: String { self.rawValue }
    
    var offsetInMinutes: Int? {
        switch self {
        case .none: return 0
        case .tenMinutes: return 10
        case .thirtyMinutes: return 30
        case .oneHour: return 60
        }
    }
}

