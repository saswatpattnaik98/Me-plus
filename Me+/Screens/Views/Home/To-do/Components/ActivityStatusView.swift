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
        } else {
            if !activity.subtasks.isEmpty {
                Text("\(activity.subtasks.count) subtasks" + (activity.isRepeating ? " • Repeating" : ""))
                    .font(.system(size: 9))
            } else {
                Text("Anytime")
                    .font(.system(size: 9))
                    .strikethrough(activity.isCompleted, pattern: .solid, color: .black)
            }
        }
    }
}
