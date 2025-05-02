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
    @Published var showTimePicker = true
    @Published var showEditTime = false
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
    func scheduleNotification(for baseDate: Date) {
        var finalDate = baseDate
        
        if let offset = reminderTime.offsetInMinutes {
            finalDate = Calendar.current.date(byAdding: .minute, value: -offset, to: baseDate) ?? baseDate
        }
        
        let calendar = Calendar.current
        
        switch selectedRepeat {
        case .None:
            let components = calendar.dateComponents([.hour, .minute], from: finalDate)
            AddhabitViewModel.notificationManager.scheduleNotification(title: "Habit Reminder", body: habitName, dateComponents: components, repeats: false)
            
        case .daily:
            let components = calendar.dateComponents([.hour, .minute], from: finalDate)
            AddhabitViewModel.notificationManager.scheduleNotification(title: "Habit Reminder", body: habitName, dateComponents: components, repeats: true)
            
        case .weekends:
            for weekday in [7, 1] { // Sunday (1), Saturday (7)
                var components = calendar.dateComponents([.hour, .minute], from: finalDate)
                components.weekday = weekday
                AddhabitViewModel.notificationManager.scheduleNotification(title: "Weekend Habit Reminder", body: habitName, dateComponents: components, repeats: true)
            }
            
        case .monthly:
            let components = calendar.dateComponents([.day, .hour, .minute], from: finalDate)
            AddhabitViewModel.notificationManager.scheduleNotification(title: "Monthly Habit Reminder", body: habitName, dateComponents: components, repeats: true)
        }
    }
    
    
    // SCHEDULE ALARM -----
    
    func scheduleAlarm(for baseDate: Date) {
        var finalDate = baseDate
        
        if let offset = reminderTime.offsetInMinutes {
            finalDate = Calendar.current.date(byAdding: .minute, value: -offset, to: baseDate) ?? baseDate
        }
        
        let calendar = Calendar.current
        let title = "Habit Alarm"
        let message = habitName

        switch selectedRepeat {
        case .None:
            AlarmManager.shared.scheduleAlarm(at: finalDate, title: title, message: message)
            
        case .daily:
            let components = calendar.dateComponents([.hour, .minute], from: finalDate)
            for _ in 0..<7 {
                if let nextDate = calendar.nextDate(after: Date(), matching: components, matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .forward) {
                    AlarmManager.shared.scheduleAlarm(at: nextDate, title: title, message: message)
                }
            }
            
        case .weekends:
            for weekday in [1, 7] { // Sunday and Saturday
                var components = calendar.dateComponents([.hour, .minute], from: finalDate)
                components.weekday = weekday
                if let nextWeekend = calendar.nextDate(after: Date(), matching: components, matchingPolicy: .nextTimePreservingSmallerComponents) {
                    AlarmManager.shared.scheduleAlarm(at: nextWeekend, title: "Weekend Habit Alarm", message: message)
                }
            }
            
        case .monthly:
            let components = calendar.dateComponents([.day, .hour, .minute], from: finalDate)
            if let nextMonthDate = calendar.nextDate(after: Date(), matching: components, matchingPolicy: .nextTimePreservingSmallerComponents) {
                AlarmManager.shared.scheduleAlarm(at: nextMonthDate, title: "Monthly Habit Alarm", message: message)
            }
        }
    }

    // Add Subtask
    func addSubtask() {
        guard !subtaskName.isEmpty else { return }
        let newSubtask = Subtask(name: subtaskName, isCompleted: false)
        subtasks.append(newSubtask)
        subtaskName = "" // Clear the field
    }
}
