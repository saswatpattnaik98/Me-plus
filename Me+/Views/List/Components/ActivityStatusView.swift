//
//  ActivityStatusView.swift
//  Me+
//
//  Created by Hari's Mac on 03.06.2025.
//

import SwiftUI

struct ActivityStatusView: View {
    let activity: Activity
    let isAnimatingCompletion: Bool
    
    var body: some View {
        if activity.isRescheduled {
            HStack(spacing: 4) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 8))
                    .foregroundColor(.red)
                    .symbolEffect(.bounce, value: isAnimatingCompletion)
                Text("Missed")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.red)
            }
        } else if activity.movedFromPast{
            HStack(spacing: 4){
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 8))
                    .foregroundColor(.blue)
                    .symbolEffect(.bounce, value: isAnimatingCompletion)
                Text("Moved from past")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.blue)
            }
        }
        else{
            // Check if task has both subtasks and reminder time
            if !activity.subtasks.isEmpty && activity.reminderType != "No reminder" {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(activity.subtasks.count) subtasks" + (activity.isRepeating ? " • Repeating" : ""))
                        .font(.system(size: 7))
                        .foregroundStyle(.gray)
                    Text("Scheduled: \(activity.reminderTime.displayTime)")
                        .font(.system(size: 7))
                        .foregroundStyle(.gray)
                }
            }
            // Check if task has only reminder time (no subtasks)
            else if activity.reminderType != "No reminder" {
                Text("Scheduled: \(activity.reminderTime.displayTime)")
                    .font(.system(size: 9))
                    .foregroundStyle(.gray)
            }
            // Check if task has only subtasks (no reminder time)
            else if !activity.subtasks.isEmpty {
                Text("\(activity.subtasks.count) subtasks" + (activity.isRepeating ? " • Repeating" : ""))
                    .font(.system(size: 9))
                    .foregroundStyle(.gray)
            }
            // No time and no subtasks - show "Anytime"
            else {
                Text("Anytime")
                    .font(.system(size: 9))
                    .foregroundStyle(.gray)
                    .strikethrough(activity.isCompleted, pattern: .solid, color: .black)
            }
        }
    }
}
