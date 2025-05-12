import Foundation
import SwiftUI
import SwiftData

class EditHabitViewModel: AddhabitViewModel {
    
    private var originalActivity: Activity
    
    init(activity: Activity) {
        self.originalActivity = activity
        super.init()
        
        // Initialize the fields using the passed activity
        self.habitID = activity.id
        self.habitName = activity.name
        self.date = activity.date
        self.tempduration = activity.duration
        self.subtasks = activity.subtasks
        self.selectedRepeat = .None // You can extract this from activity if you store it
    }
    
    func updateActivity(in context: ModelContext) {
        originalActivity.name = habitName
        originalActivity.date = date
        originalActivity.duration = tempduration
        originalActivity.subtasks = subtasks
        originalActivity.isCompleted = false
        
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
        
        // Persist changes
        try? context.save()
    }
}
