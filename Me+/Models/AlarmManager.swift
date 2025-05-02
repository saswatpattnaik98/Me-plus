import SwiftUI
import UserNotifications
import AVFoundation

class AlarmManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = AlarmManager()
    
    private var audioPlayer: AVAudioPlayer?
    @Published var isAlarmActive = false
    let alarmCategoryIdentifier = "ALARM_CATEGORY"
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        setupNotificationCategories()
        setupAudioSession()
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
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge, .criticalAlert]
        ) { granted, error in
            if granted {
                print("Notification permissions granted")
            } else {
                print("Notification permissions denied: \(String(describing: error))")
            }
        }
    }
    
    func scheduleAlarm(at date: Date, title: String, message: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = UNNotificationSound.criticalSoundNamed(
            UNNotificationSoundName("alarm.wav"),
            withAudioVolume:  2.0
        )
        content.categoryIdentifier = alarmCategoryIdentifier
        
        if #available(iOS 15.0, *) {
            content.interruptionLevel = .critical
        }

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let identifier = "alarm_\(date.timeIntervalSince1970)"
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling alarm: \(error)")
            } else {
                print("Alarm scheduled for \(date)")
            }
        }
    }
    
    func startAlarm() {
        guard let url = Bundle.main.url(forResource: "alarm", withExtension: "wav") else {
            print("Alarm sound not found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
            isAlarmActive = true
        } catch {
            print("Error playing alarm: \(error)")
        }
    }
    
    func stopAlarm() {
        audioPlayer?.stop()
        audioPlayer = nil
        isAlarmActive = false
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    func snoozeAlarm(for minutes: Int = 5) {
        stopAlarm()
        let snoozeDate = Date().addingTimeInterval(TimeInterval(minutes * 60))
        scheduleAlarm(at: snoozeDate, title: "Snoozed Alarm", message: "Your alarm after snooze")
    }
    
    // MARK: - Notification Handling
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        startAlarm()
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .list, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case "STOP_ACTION":
            stopAlarm()
        case "SNOOZE_ACTION":
            snoozeAlarm()
        case UNNotificationDefaultActionIdentifier:
            startAlarm()
        case UNNotificationDismissActionIdentifier:
            break
        default:
            startAlarm()
        }
        completionHandler()
    }
}

