import SwiftUI
import UserNotifications
import AVFoundation

class AlarmManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = AlarmManager()

    private var audioPlayers: [UUID: AVAudioPlayer] = [:]
    @Published var activeAlarmIDs: Set<UUID> = []
    let alarmCategoryIdentifier = "ALARM_CATEGORY"

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        setupNotificationCategories()
        setupAudioSession()
        checkSoundFileExists()
        requestNotificationPermission() // Request permissions at initialization
    }

    private func setupNotificationCategories() {
        let stopAction = UNNotificationAction(
            identifier: "STOP_ACTION",
            title: "Stop",
            options: [.destructive]
        )

        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: "Snooze",
            options: []
        )

        let category = UNNotificationCategory(
            identifier: alarmCategoryIdentifier,
            actions: [stopAction, snoozeAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }

    func checkSoundFileExists() {
        if let path = Bundle.main.path(forResource: "alarm", ofType: "wav") {
            print("✅ Sound file exists at: \(path)")
        } else {
            print("❌ Sound file NOT found in bundle")
        }
    }

    func checkNotificationPermissions() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings.authorizationStatus.rawValue)")
            print("Critical alerts enabled: \(settings.criticalAlertSetting.rawValue)")
            print("Sound setting: \(settings.soundSetting.rawValue)")
        }
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge, .criticalAlert]
        ) { granted, error in
            if granted {
                print("✅ Notification permissions granted")
                
                // Register for remote notifications on main thread
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("❌ Notification permissions denied: \(String(describing: error))")
            }
        }
    }

    func scheduleAlarm(for activityID: UUID, at date: Date, title: String, message: String) {
        // Debug output to verify timing
        print("Scheduling alarm for: \(date), current time: \(Date())")
        
        // Check if date is in the past
        if date < Date() {
            print("⚠️ Warning: Trying to schedule alarm in the past")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        
        // Store activity ID in userInfo for reference
        content.userInfo = ["activityID": activityID.uuidString]
        
        // Check if sound file exists before using it
        if Bundle.main.path(forResource: "alarm", ofType: "wav") != nil {
            content.sound = UNNotificationSound.criticalSoundNamed(
                UNNotificationSoundName("alarm.wav"),
                withAudioVolume: 1.0
            )
        } else {
            print("❌ Alarm sound not found, using default")
            content.sound = UNNotificationSound.default
        }
        
        content.categoryIdentifier = alarmCategoryIdentifier

        if #available(iOS 15.0, *) {
            content.interruptionLevel = .critical
        }

        // Create trigger with more precision
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let identifier = "alarm_\(activityID.uuidString)"

        // Clean up existing notifications
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling alarm: \(error)")
            } else {
                print("✅ Alarm scheduled for activity \(activityID) at \(date)")
                
                // Verify the scheduled notification was added
                self.checkPendingNotifications()
            }
        }
    }

    func startAlarm(for activityID: UUID) {
        guard let url = Bundle.main.url(forResource: "alarm", withExtension: "wav") else {
            print("❌ Alarm sound file not found")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            player.volume = 1.0
            
            // Make sure audio session is active
            try AVAudioSession.sharedInstance().setActive(true)
            
            player.play()

            audioPlayers[activityID] = player
            activeAlarmIDs.insert(activityID)

            print("✅ Alarm started playing for \(activityID)")
        } catch {
            print("❌ Error playing alarm: \(error)")
        }
    }

    func stopAlarm(for activityID: UUID) {
        if let player = audioPlayers[activityID] {
            player.stop()
            audioPlayers.removeValue(forKey: activityID)
            activeAlarmIDs.remove(activityID)
            print("✅ Alarm stopped for \(activityID)")
        }

        // Also cancel pending notifications
        let identifier = "alarm_\(activityID.uuidString)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    func snoozeAlarm(for activityID: UUID, minutes: Int = 5) {
        stopAlarm(for: activityID)

        let snoozeDate = Date().addingTimeInterval(TimeInterval(minutes * 60))
        scheduleAlarm(for: activityID, at: snoozeDate, title: "Snoozed Alarm", message: "Your alarm after snooze")
        
        print("⏰ Alarm snoozed for \(minutes) minutes")
    }
    
    func checkPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("Current pending notifications: \(requests.count)")
            for request in requests {
                print("- ID: \(request.identifier)")
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    if let nextDate = trigger.nextTriggerDate() {
                        print("  Next trigger date: \(nextDate)")
                    } else {
                        print("  No next trigger date available")
                    }
                }
                
                // Print userInfo for debugging
                if let userInfo = request.content.userInfo as? [String: String],
                   let activityID = userInfo["activityID"] {
                    print("  For activity: \(activityID)")
                }
            }
        }
    }
    
    func cancelAllAlarmsForActivity(activityID: UUID) {
        // Stop any playing alarm
        stopAlarm(for: activityID)
        
        // Also need to handle possible recurring alarms with derived IDs
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            var identifiersToRemove: [String] = []
            
            for request in requests {
                // Check if the identifier contains our activity ID
                if request.identifier.contains(activityID.uuidString) {
                    identifiersToRemove.append(request.identifier)
                }
                
                // Also check the userInfo dictionary
                if let userInfo = request.content.userInfo as? [String: String],
                   let storedID = userInfo["activityID"],
                   storedID == activityID.uuidString {
                    identifiersToRemove.append(request.identifier)
                }
            }
            
            if !identifiersToRemove.isEmpty {
                print("🗑️ Removing \(identifiersToRemove.count) notifications for activity \(activityID)")
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
            }
        }
    }

    // MARK: - Notification Handling

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                                 withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // Extract activity ID from notification
        let activityID = extractActivityID(from: notification.request.identifier)
        if let id = activityID {
            startAlarm(for: id)
        } else if let userInfo = notification.request.content.userInfo as? [String: String],
                  let idString = userInfo["activityID"],
                  let id = UUID(uuidString: idString) {
            startAlarm(for: id)
        }

        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .list, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
                                 withCompletionHandler completionHandler: @escaping () -> Void) {
        print("📱 User responded to notification: \(response.actionIdentifier)")
        
        // Try both methods to extract activity ID
        var activityID: UUID? = extractActivityID(from: response.notification.request.identifier)
        
        // If not found in identifier, check userInfo
        if activityID == nil,
           let userInfo = response.notification.request.content.userInfo as? [String: String],
           let idString = userInfo["activityID"] {
            activityID = UUID(uuidString: idString)
        }

        switch response.actionIdentifier {
        case "STOP_ACTION":
            if let id = activityID {
                stopAlarm(for: id)
                print("🛑 Alarm stopped via notification action")
            }
            
        case "SNOOZE_ACTION":
            if let id = activityID {
                snoozeAlarm(for: id)
                print("⏰ Alarm snoozed via notification action")
            }
            
        case UNNotificationDefaultActionIdentifier:
            // User tapped the notification - just open the app, don't restart alarm
            print("📱 Notification tapped - opening app")
            // You can add navigation logic here if needed
            
        case UNNotificationDismissActionIdentifier:
            print("🔕 Notification dismissed")
            
        default:
            // Don't start alarm for unknown actions either
            print("❓ Unknown notification action: \(response.actionIdentifier)")
        }

        completionHandler()
    }

    // Extract UUID from notification identifier
    private func extractActivityID(from identifier: String) -> UUID? {
        if identifier.hasPrefix("alarm_") {
            let idString = identifier.replacingOccurrences(of: "alarm_", with: "")
            return UUID(uuidString: idString)
        }
        return nil
    }
}
