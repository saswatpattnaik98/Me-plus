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
                print("Notification error: \(error.localizedDescription)")
            } else {
                print("Notification scheduled with ID: \(id)")
            }
        }
    }

    // Cancel only the notification for this activity
    func cancelNotification(for id: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
        print("Cancelled notification for ID: \(id)")
    }

    // Use only for global resets/debug
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("All notifications cancelled")
    }
}
