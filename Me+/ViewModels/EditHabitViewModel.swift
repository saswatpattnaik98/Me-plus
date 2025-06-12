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
        // CRITICAL FIX: Cancel existing notifications/alarms BEFORE scheduling new ones
        let notificationManager = LocalNotificationManager()
        let alarmManager = AlarmManager()
        
        // Cancel old notifications/alarms for this specific activity
        notificationManager.cancelNotification(for: originalActivity.id)
        alarmManager.stopAlarm(for: originalActivity.id)
        
        // If this activity has a baseID, cancel all related notifications too
        if let baseID = originalActivity.baseID {
            // Get all activities with the same baseID from context
            let descriptor = FetchDescriptor<Activity>(
                predicate: #Predicate<Activity> { $0.baseID == baseID }
            )
            
            if let relatedActivities = try? context.fetch(descriptor) {
                print("🚫 Cancelling notifications for \(relatedActivities.count) related activities")
                for activity in relatedActivities {
                    notificationManager.cancelNotification(for: activity.id)
                    alarmManager.stopAlarm(for: activity.id)
                }
            }
        }
        
        // Update the activity properties
        originalActivity.name = habitName
        originalActivity.date = date
        originalActivity.duration = tempduration
        originalActivity.subtasks = subtasks
        originalActivity.isCompleted = false
        
        // Update reminder properties in the activity
        originalActivity.reminderType = reminderType
        originalActivity.reminderTime = time
        originalActivity.repeatOption = selectedRepeat.rawValue
        
        // 🔥 CRITICAL FIX: Set baseID for the original activity when making it repeating
        if selectedRepeat != .None {
            originalActivity.baseID = originalActivity.id  // Set baseID to its own ID (isRepeating will automatically be true)
            print("✅ Set original activity baseID to: \(originalActivity.id)")
            print("✅ isRepeating is now: \(originalActivity.isRepeating)")
        } else {
            originalActivity.baseID = nil                  // Clear baseID if not repeating (isRepeating will automatically be false)
            print("✅ Cleared baseID, isRepeating is now: \(originalActivity.isRepeating)")
        }
        
        // Store reminderOffset in UserDefaults temporarily
        let key = "reminderOffset_\(originalActivity.id.uuidString)"
        UserDefaults.standard.set(reminderTime.rawValue, forKey: key)
        
        // NOW schedule new notifications/alarms with updated properties
        if reminderType == "Notification" {
            if let baseDate = combineDateAndTime(date: date, time: time) {
                scheduleNotification(for: baseDate, activityId: habitID)
            }
        } else if reminderType == "Alarm" {
            if let baseDate = combineDateAndTime(date: date, time: time) {
                scheduleAlarm(for: habitID, baseDate: baseDate)
            }
        }
        
        // Handle repeated activities
        if selectedRepeat != .None {
            createRepeatedActivities(baseActivity: originalActivity, baseID: habitID, context: context)
        }
        
        // Persist changes
        do {
            try context.save()
            print("✅ Activity updated and saved successfully")
            print("   - Original activity baseID: \(originalActivity.baseID?.uuidString ?? "nil")")
            print("   - Original activity isRepeating: \(originalActivity.isRepeating)")
            
            // Debug: Check what notifications are scheduled after update
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                notificationManager.checkPendingNotifications()
            }
        } catch {
            print("❌ Error saving updated activity: \(error)")
        }
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

    private func insertActivityIfNeeded(on date: Date, base: Activity, baseID: UUID, context: ModelContext) {
        // Create deep copies of subtasks instead of sharing references
        let copiedSubtasks = base.subtasks.map { originalSubtask in
            Subtask(
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
            subtasks: copiedSubtasks,
            reminderType: base.reminderType,
            reminderTime: base.reminderTime,
            repeatOption: base.repeatOption
        )
        
        // Store reminderOffset for the new activity
        let baseKey = "reminderOffset_\(base.id.uuidString)"
        let newKey = "reminderOffset_\(newActivity.id.uuidString)"
        if let baseOffset = UserDefaults.standard.string(forKey: baseKey) {
            UserDefaults.standard.set(baseOffset, forKey: newKey)
        }
        
        context.insert(newActivity)
        
        // CRITICAL FIX: Schedule notifications/alarms for the new repeated activity
        let notificationManager = LocalNotificationManager()
        let alarmManager = AlarmManager()
        
        if base.reminderType == "Notification" {
            if let reminderDate = combineDateAndTime(date: date, time: base.reminderTime) {
                scheduleNotification(for: reminderDate, activityId: newActivity.id)
            }
        } else if base.reminderType == "Alarm" {
            if let reminderDate = combineDateAndTime(date: date, time: base.reminderTime) {
                scheduleAlarm(for: newActivity.id, baseDate: reminderDate)
            }
        }
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
