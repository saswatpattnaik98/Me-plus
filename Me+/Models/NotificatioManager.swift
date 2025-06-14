import UserNotifications

class LocalNotificationManager {
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            print("Notification permission granted: \(granted)")
        }
    }

    // Use the activity ID as identifier
    func scheduleNotification(
        id: UUID,
        title: String,
        body: String,
        dateComponents: DateComponents,
        repeats: Bool = false
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .defaultCritical

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats)
        let request = UNNotificationRequest(identifier: id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Notification error: \(error.localizedDescription)")
            } else {
                print("✅ Notification scheduled with ID: \(id)")
                print("📅 Date Components: \(dateComponents)")
                print("🔄 Repeats: \(repeats)")
            }
        }
    }

    // Cancel only the notification for this activity
    func cancelNotification(for id: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
        print("🗑️ Cancelled notification for ID: \(id)")
    }

    // Use only for global resets/debug
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🗑️ All notifications cancelled")
    }
    
    // Debug method to check what's actually scheduled
    func checkPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("\n=== 📋 PENDING NOTIFICATIONS ===")
            for request in requests {
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    print("🆔 ID: \(request.identifier)")
                    print("📰 Title: \(request.content.title)")
                    print("💬 Body: \(request.content.body)")
                    print("📅 Date Components: \(trigger.dateComponents)")
                    print("🔄 Repeats: \(trigger.repeats)")
                    
                    // Try to create a readable date from components
                    if let date = Calendar.current.date(from: trigger.dateComponents) {
                        let formatter = DateFormatter()
                        formatter.dateStyle = .medium
                        formatter.timeStyle = .short
                        print("📆 Readable Date: \(formatter.string(from: date))")
                    }
                    print("---")
                }
            }
            print("📊 Total pending: \(requests.count)")
            print("===============================\n")
        }
    }
}
