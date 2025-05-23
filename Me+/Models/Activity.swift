import SwiftUI
import SwiftData

@Model
class Activity: ObservableObject {
    var id: UUID
    var baseID: UUID?
    var name: String
    var date: Date
    var duration: Int // This is the streak we are maintaining
    var colorName: String
    var isCompleted: Bool
    var isRescheduled: Bool = false
    @Relationship var subtasks: [Subtask] // Corrected: `subtasks` instead of `subtask`

    // Updated initializer to accept subtasks
    init(id: UUID = UUID(), baseID: UUID? = nil,name: String, date: Date, duration: Int, colorName: String = Activity.randomColorName(), isCompleted: Bool = false, isRescheduled: Bool = false, subtasks: [Subtask] = []) {
        self.id = id
        self.baseID = baseID
        self.name = name
        self.date = date
        self.duration = duration
        self.colorName = colorName
        self.isCompleted = isCompleted
        self.isRescheduled = isRescheduled
        self.subtasks = subtasks // Now accepting subtasks
    }

    static func randomColorName() -> String {
        let colorOptions = ["red", "blue", "green", "purple", "orange", "pink", "indigo", "teal"]
        return colorOptions.randomElement() ?? "blue"
    }

    var color: Color {
        switch colorName {
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "purple": return .purple
        case "orange": return .orange
        case "pink": return .pink
        case "indigo": return .indigo
        case "teal": return .teal
        default: return .blue
        }
    }
    
    /// Computed property to check if this task is part of a repeating series
        var isRepeating: Bool {
            return baseID != nil
        }
        
        /// Function to check if this task is repeating (alternative approach)
        func isTaskRepeating() -> Bool {
            return baseID != nil
        }
        
        /// Check if this activity has other instances (past or future)
        /// You would call this with your modelContext
        func hasOtherInstances(in activities: [Activity]) -> Bool {
            guard let baseID = self.baseID else { return false }
            
            return activities.contains { activity in
                activity.baseID == baseID && activity.id != self.id
            }
        }
}


