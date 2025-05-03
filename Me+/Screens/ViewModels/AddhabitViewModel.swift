import Foundation
import SwiftUI
import SwiftData

class AddhabitViewModel:ObservableObject{
    let ReminderType = ["No reminder", "Notification", "Alarm"]
    @Published var habitName:String = ""
    @Published var alarmDate: Date = Date()
    @Published var date: Date = Date()
    @Published var tempduration: Int = 0
    @Published var selectedRepeat: RepeatOption = .None
    @Published var  reminderTime: ReminderOffset = .none
    @Published var reminderType: String = "Notification"
    @Published var subtaskName: String = ""
    @Published var subtasks: [Subtask] = []
    @Published var  periodTime = false
    @Published var showTimePicker = false
    @Published var showEditTime = false
    @Published var showrepeatPicker = false
    @Published var endTime = Date()
    @Published var time: Date = Date().addingTimeInterval(15 * 60)
    
    @Published var selectedColor: Color = Color.green.opacity(0.3)
    
    static let notificationManager = LocalNotificationManager()  // Singleton instance
     init() {}
    // MARK: - Combine Date and Time
    func combineDateAndTime(date: Date, time: Date) -> Date? {
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute
        
        return calendar.date(from: dateComponents)
    }
    
    // MARK: - Schedule Notification
    func scheduleNotification(for baseDate: Date, activityId: UUID) {
        var finalDate = baseDate
        
        if let offset = reminderTime.offsetInMinutes {
            finalDate = Calendar.current.date(byAdding: .minute, value: -offset, to: baseDate) ?? baseDate
        }
        
        let calendar = Calendar.current
        
        switch selectedRepeat {
        case .None:
            let components = calendar.dateComponents([.hour, .minute], from: finalDate)
            AddhabitViewModel.notificationManager.scheduleNotification(
                id: activityId,
                title: "Reminder",
                body: habitName,
                dateComponents: components,
                repeats: false
            )
            
        case .daily:
            let components = calendar.dateComponents([.hour, .minute], from: finalDate)
            AddhabitViewModel.notificationManager.scheduleNotification(
                id: activityId,
                title: "Reminder",
                body: habitName,
                dateComponents: components,
                repeats: true
            )
            
        case .weekends:
            for weekday in [7, 1] { // Saturday (7), Sunday (1)
                var components = calendar.dateComponents([.hour, .minute], from: finalDate)
                components.weekday = weekday
                let weekendId = UUID() // Optional: generate unique ID per weekend notification
                AddhabitViewModel.notificationManager.scheduleNotification(
                    id: weekendId,
                    title: "Weekend Reminder",
                    body: habitName,
                    dateComponents: components,
                    repeats: true
                )
            }
            
        case .monthly:
            let components = calendar.dateComponents([.day, .hour, .minute], from: finalDate)
            AddhabitViewModel.notificationManager.scheduleNotification(
                id: activityId,
                title: "Monthly Reminder",
                body: habitName,
                dateComponents: components,
                repeats: true
            )
        }
    }

    
    // Alarm scheduler
    func scheduleAlarm(for activityID: UUID, baseDate: Date) {
        var finalDate = baseDate

        if let offset = reminderTime.offsetInMinutes {
            finalDate = Calendar.current.date(byAdding: .minute, value: -offset, to: baseDate) ?? baseDate
        }

        let calendar = Calendar.current
        let title = "Reminder"
        let message = habitName
        
        // Log for debugging
        print("Scheduling alarm for \(habitName), base date: \(baseDate), final date: \(finalDate)")
        
        // Check if finalDate is in the past
        if finalDate < Date(){
            print(" Warning: Original alarm date is in the past, adjusting...")
            // Adjust to next occurrence
            finalDate = calendar.nextDate(after: Date(),
                       matching: calendar.dateComponents([.hour, .minute], from: finalDate),
                       matchingPolicy: .nextTime) ?? Date().addingTimeInterval(60)
        }

        switch selectedRepeat {
        case .None:
            // Single alarm
            AlarmManager.shared.scheduleAlarm(for: activityID, at: finalDate, title: title, message: message)
            print("Scheduled one-time alarm for: \(finalDate)")

        case .daily:
            // Schedule for the next 7 days with unique IDs
            var currentDate = finalDate
            for i in 0..<7 {
                // Generate a deterministic UUID based on the activity ID and day number
                let dailyID = UUID(uuidString: "\(activityID.uuidString)-\(i)")!
                
                AlarmManager.shared.scheduleAlarm(for: dailyID, at: currentDate, title: title, message: message)
                print("Scheduled daily alarm \(i+1) for: \(currentDate)")
                
                // Advance to next day
                if let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                    currentDate = nextDay
                }
            }

        case .weekends:
            // Get current components
            var dayComponent = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: finalDate)
            
            // Find the next Saturday and Sunday
            let currentWeekday = calendar.component(.weekday, from: Date())
            
            for targetWeekday in [1, 7] { // 1=Sunday, 7=Saturday
                // Calculate days to add
                var daysToAdd = targetWeekday - currentWeekday
                if daysToAdd <= 0 {
                    daysToAdd += 7 // Move to next week
                }
                
                // Create a new date by adding the calculated days
                if let weekendDate = calendar.date(byAdding: .day, value: daysToAdd, to: Date()) {
                    // Keep the original time
                    let weekendWithTime = calendar.date(
                        bySettingHour: calendar.component(.hour, from: finalDate),
                        minute: calendar.component(.minute, from: finalDate),
                        second: 0,
                        of: weekendDate
                    ) ?? weekendDate
                    
                    // Generate unique ID for this weekend
                    let weekendID = UUID(uuidString: "\(activityID.uuidString)-\(targetWeekday)")!
                    
                    AlarmManager.shared.scheduleAlarm(
                        for: weekendID,
                        at: weekendWithTime,
                        title: "Weekend Reminder",
                        message: message
                    )
                    print("Scheduled weekend alarm for \(targetWeekday == 1 ? "Sunday" : "Saturday"): \(weekendWithTime)")
                }
            }

        case .monthly:
            // Get the day of month
            let day = calendar.component(.day, from: finalDate)
            let hour = calendar.component(.hour, from: finalDate)
            let minute = calendar.component(.minute, from: finalDate)
            
            // Find the next month's date
            var dateComponents = DateComponents()
            dateComponents.day = day
            dateComponents.hour = hour
            dateComponents.minute = minute
            
            var currentDate = Date()
            
            // Handle case if we're already past this day in current month
            if calendar.component(.day, from: currentDate) > day {
                // Move to next month
                currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
            }
            
            // Set to the day in the current or next month
            if let nextMonthDate = calendar.nextDate(
                after: currentDate,
                matching: dateComponents,
                matchingPolicy: .nextTime
            ) {
                let monthlyID = UUID(uuidString: "\(activityID.uuidString)-monthly")!
                
                AlarmManager.shared.scheduleAlarm(
                    for: monthlyID,
                    at: nextMonthDate,
                    title: "Monthly Reminder",
                    message: message
                )
                print("Scheduled monthly alarm for: \(nextMonthDate)")
            }
        }
        
        // Verify pending notifications after scheduling
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            AlarmManager.shared.checkPendingNotifications()
        }
    }


    // Add Subtask
    func addSubtask() {
        guard !subtaskName.isEmpty else { return }
        let newSubtask = Subtask(name: subtaskName, isCompleted: false)
        subtasks.append(newSubtask)
        subtaskName = "" // Clear the field
    }
    // Repat Tasks
    func createRepeatedActivities(baseActivity: Activity, context: ModelContext) {
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
                    insertActivityIfNeeded(on: nextDate, base: baseActivity, context: context)

                case .monthly:
                    insertActivityIfNeeded(on: nextDate, base: baseActivity, context: context)

                case .weekends:
                    if weekday == 1 || weekday == 7 { // Sunday or Saturday
                        insertActivityIfNeeded(on: nextDate, base: baseActivity, context: context)
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

    // Helper to insert activity
    private func insertActivityIfNeeded(on date: Date, base: Activity, context: ModelContext) {
        let newActivity = Activity(
            name: base.name,
            date: date,
            duration: base.duration,
            isCompleted: false,
            subtasks: base.subtasks
        )
        context.insert(newActivity)
    }

}
