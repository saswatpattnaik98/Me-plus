//
//  Me_App.swift
//  Me+
//
//  Created by Hari's Mac on 02.05.2025.
//

import SwiftUI
import SwiftData


@main
struct Me_App: App {
    @StateObject private var alarmManager = AlarmManager.shared
        init() {
            // Request permissions on app launch
            AlarmManager.shared.requestNotificationPermission()
        }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(alarmManager)
        }
        .modelContainer(for: [Activity.self])
    }
}
