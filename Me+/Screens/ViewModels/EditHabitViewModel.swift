import Foundation
import SwiftUI
import SwiftData

class EditHabitViewModel: AddhabitViewModel {
    
    private var originalActivity: Activity
    
    init(activity: Activity) {
        self.originalActivity = activity
        super.init()
        
        // Initialize all fields using the passed activity
        syncWithActivity()
    }
    
    private func syncWithActivity() {
        self.habitID = originalActivity.id
        self.habitName = originalActivity.name
        self.date = originalActivity.date
        self.tempduration = originalActivity.duration
        self.subtasks = originalActivity.subtasks
        
        // Sync reminder properties from the activity
        self.reminderType = originalActivity.reminderType
        self.time = originalActivity.reminderTime
        self.selectedRepeat = originalActivity.repeatOptionEnum
        
        // FIX: Use UserDefaults to store/retrieve reminderOffset since Activity model doesn't have it yet
        let key = "reminderOffset_\(originalActivity.id.uuidString)"
        if let storedOffsetString = UserDefaults.standard.string(forKey: key),
           let offset = ReminderOffset(rawValue: storedOffsetString) {
            self.reminderTime = offset
        } else {
            self.reminderTime = .none
        }
    }
    
    // Add this method to refresh from activity when needed
    func refreshFromActivity() {
        syncWithActivity()
    }
    
    func updateActivity(in context: ModelContext) {
        originalActivity.name = habitName
        originalActivity.date = date
        originalActivity.duration = tempduration
        originalActivity.subtasks = subtasks
        originalActivity.isCompleted = false
        
        // Update reminder properties in the activity
        originalActivity.reminderType = reminderType
        originalActivity.reminderTime = time
        originalActivity.repeatOption = selectedRepeat.rawValue
        
        // FIX: Store reminderOffset in UserDefaults temporarily
        let key = "reminderOffset_\(originalActivity.id.uuidString)"
        UserDefaults.standard.set(reminderTime.rawValue, forKey: key)
        
        // Optional: handle alarm/notification updates
        if reminderType == "Notification" {
            if let baseDate = combineDateAndTime(date: date, time: time) {
                scheduleNotification(for: baseDate, activityId: habitID)
            }
        } else if reminderType == "Alarm" {
            if let baseDate = combineDateAndTime(date: date, time: time) {
                scheduleAlarm(for: habitID, baseDate: baseDate)
            }
        }
        
        if selectedRepeat != .None {
            createRepeatedActivities(baseActivity: originalActivity, baseID: habitID, context: context)
        }
        
        // Persist changes
        try? context.save()
    }
    
    override func createRepeatedActivities(baseActivity: Activity, baseID: UUID, context: ModelContext) {
        let repeatType = selectedRepeat
        let calendar = Calendar.current
        var nextDate = baseActivity.date

        // Repeat for 3 months max
        let repeatEnd = calendar.date(byAdding: .month, value: 3, to: nextDate)!

        while nextDate <= repeatEnd {
            if nextDate != baseActivity.date {
                let weekday = calendar.component(.weekday, from: nextDate)

                switch repeatType {
                case .daily:
                    insertActivityIfNeeded(on: nextDate, base: baseActivity, baseID: baseID, context: context)

                case .monthly:
                    insertActivityIfNeeded(on: nextDate, base: baseActivity, baseID: baseID, context: context)

                case .weekends:
                    if weekday == 1 || weekday == 7 { // Sunday or Saturday
                        insertActivityIfNeeded(on: nextDate, base: baseActivity, baseID: baseID, context: context)
                    }

                default:
                    return
                }
            }
            // Increment nextDate
            switch repeatType {
            case .daily, .weekends:
                nextDate = calendar.date(byAdding: .day, value: 1, to: nextDate)!
            case .monthly:
                nextDate = calendar.date(byAdding: .month, value: 1, to: nextDate)!
            default:
                break
            }
        }
    }

    // FIXED: Helper to insert activity with proper subtask copying
    private func insertActivityIfNeeded(on date: Date, base: Activity, baseID: UUID, context: ModelContext) {
        // FIX: Create deep copies of subtasks instead of sharing references
        let copiedSubtasks = base.subtasks.map { originalSubtask in
            Subtask(
                //id: UUID(), // New unique ID for each copy
                name: originalSubtask.name,
                isCompleted: originalSubtask.isCompleted
            )
        }
        
        let newActivity = Activity(
            id: UUID(),
            baseID: baseID,
            name: base.name,
            date: date,
            duration: base.duration,
            colorName: base.colorName,
            isCompleted: false,
            subtasks: copiedSubtasks, // Use copied subtasks
            // Include all reminder properties when creating repeated activities
            reminderType: base.reminderType,
            reminderTime: base.reminderTime,
            repeatOption: base.repeatOption
        )
        
        // Store reminderOffset for the new activity too
        let baseKey = "reminderOffset_\(base.id.uuidString)"
        let newKey = "reminderOffset_\(newActivity.id.uuidString)"
        if let baseOffset = UserDefaults.standard.string(forKey: baseKey) {
            UserDefaults.standard.set(baseOffset, forKey: newKey)
        }
        
        context.insert(newActivity)
    }
    
    // RECOMMENDED: ID-based subtask removal (most stable)
    func removeSubtask(_ subtask: Subtask) {
        if let index = subtasks.firstIndex(where: { $0.id == subtask.id }) {
            subtasks.remove(at: index)
            objectWillChange.send()
        }
    }

    // Alternative: Safe subtask removal by index with bounds checking
    func removeSubtaskSafely(at index: Int) {
        guard index >= 0 && index < subtasks.count else {
            print("Warning: Attempted to remove subtask at invalid index \(index)")
            return
        }
        subtasks.remove(at: index)
        objectWillChange.send()
    }

    // Safe subtask addition with validation
    override func addSubtask() {
        let trimmedName = subtaskName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        
        let newSubtask = Subtask(name: trimmedName)
        subtasks.append(newSubtask)
        subtaskName = "" // Clear the input field
        objectWillChange.send()
    }

    // Safe subtask update by ID (recommended)
    func updateSubtask(id: UUID, name: String) {
        if let index = subtasks.firstIndex(where: { $0.id == id }) {
            subtasks[index].name = name
            objectWillChange.send()
        }
    }

    // Alternative: Safe subtask update by index
    func updateSubtaskSafely(at index: Int, name: String) {
        guard index >= 0 && index < subtasks.count else {
            print("Warning: Attempted to update subtask at invalid index \(index)")
            return
        }
        subtasks[index].name = name
        objectWillChange.send()
    }

    // Utility method to validate subtasks array integrity
    private func validateSubtasksArray() -> Bool {
        return !subtasks.isEmpty && subtasks.allSatisfy { !$0.name.trimmingCharacters(in: .whitespaces).isEmpty }
    }
}
