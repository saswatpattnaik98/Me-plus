//
//  CompletionButtonView.swift
//  Me+
//
//  Created by Hari's Mac on 03.06.2025.
//

import SwiftUI

// MARK: - Simplified Completion Button
struct CompletionButtonView: View {
    let activity: Activity
    let isAnimatingCompletion: Bool
    let onComplete: () -> Void
    @Binding var selectedDate: Date
    
    private var canDo: Bool {
        Calendar.current.isDate(activity.date, inSameDayAs: Date()) ||
        activity.date >= Calendar.current.startOfDay(for: Date())
    }
    
    var body: some View {
        Button(action: onComplete) {
            ZStack {
                Circle()
                    .strokeBorder(
                        activity.isCompleted ? activity.color : Color.secondary.opacity(0.4),
                        lineWidth: 2
                    )
                    .background(
                        Circle()
                            .fill(activity.isCompleted ? activity.color : Color.clear)
                    )
                    .frame(width: 20, height: 20)
                
                if activity.isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white)
                        .scaleEffect(isAnimatingCompletion ? 1.2 : 1.0)
                }
            }
        }
        .buttonStyle(.borderless)
        .disabled(!canDo)
        .opacity(!canDo ? 0.5 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: activity.isCompleted)
    }
}
