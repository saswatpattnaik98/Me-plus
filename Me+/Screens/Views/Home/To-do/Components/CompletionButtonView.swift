//
//  CompletionButtonView.swift
//  Me+
//
//  Created by Hari's Mac on 03.06.2025.
//

import SwiftUI

struct CompletionButtonView: View {
    let activity: Activity
    let isAnimatingCompletion: Bool
    let onComplete: () -> Void
    
    private var isToday: Bool {
        Calendar.current.isDate(activity.date, inSameDayAs: Date())
    }
    
    var body: some View {
        Button(action: onComplete) {
            ZStack {
                Circle()
                    .strokeBorder(activity.isCompleted ? Color.green : Color.gray.opacity(0.3), lineWidth: 2)
                    .background(Circle().fill(activity.isCompleted ? Color.green.opacity(0.1) : Color.clear))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle()
                            .fill(activity.isCompleted ? Color.green.opacity(0.3) : Color.clear)
                            .frame(width: 40, height: 40)
                            .blur(radius: 8)
                            .opacity(activity.isCompleted ? 1 : 0)
                    )
                
                if activity.isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.green)
                        .scaleEffect(isAnimatingCompletion ? 1.5 : 1.0)
                        .symbolEffect(.bounce.up, value: isAnimatingCompletion)
                }
            }
        }
        .buttonStyle(.borderless)
        .disabled(!isToday)
        .opacity(isToday ? 1.0 : 0.5)
    }
}
