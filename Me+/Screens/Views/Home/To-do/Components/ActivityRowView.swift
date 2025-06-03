//
//  ActivityRowView.swift
//  Me+
//
//  Created by Hari's Mac on 03.06.2025.
//

import SwiftUI

struct ActivityRowView: View {
    let activity: Activity
    let index: Int
    let isPressed: Bool
    let isAnimatingCompletion: Bool
    let isNewTask: Bool
    let onTap: () -> Void
    let onComplete: () -> Void
    
    var body: some View {
        HStack {
            ActivityIconView(activity: activity, isNewTask: isNewTask)
            
            VStack(alignment: .leading) {
                ActivityStatusView(activity: activity, isAnimatingCompletion: isAnimatingCompletion)
                ActivityNameView(activity: activity, isAnimatingCompletion: isAnimatingCompletion)
            }
            
            Spacer()
            
            CompletionButtonView(
                activity: activity,
                isAnimatingCompletion: isAnimatingCompletion,
                onComplete: onComplete
            )
        }
        .padding(EdgeInsets(top: 25, leading: 25, bottom: 25, trailing: 15))
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(activity.color.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(isNewTask ? 0.3 : 0),
                                    Color.white.opacity(isNewTask ? 0.1 : 0),
                                    Color.white.opacity(isNewTask ? 0.3 : 0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
        )
        .foregroundColor(.black)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .contentShape(Rectangle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .opacity(isPressed ? 0.8 : 1.0)
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
        .onTapGesture {
            onTap()
        }
        .animation(.easeInOut(duration: 0.2), value: isPressed)
    }
}

