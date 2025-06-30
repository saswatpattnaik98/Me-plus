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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var alarmManager = AlarmManager.shared
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showOnboardingTest = false
    init() {
        // Request permissions on app launch
        AlarmManager.shared.requestNotificationPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .fullScreenCover(isPresented: $showOnboardingTest) {
                   Survey()
                }
                .onAppear {
                    // Show test only on first launch
                    if !hasCompletedOnboarding {
                        showOnboardingTest = true
                    }
                }
                .ignoresSafeArea()
                .environmentObject(alarmManager)
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: [Activity.self])
    }
}
