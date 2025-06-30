//
//  ActivityNameView.swift
//  Me+
//
//  Created by Hari's Mac on 03.06.2025.
//

import SwiftUI

struct ActivityNameView: View {
    let activity: Activity
    let isAnimatingCompletion: Bool
    
    var body: some View {
        Text(activity.name)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(activity.isCompleted ? .secondary : .primary)
            .strikethrough(activity.isCompleted, pattern: .solid, color: .secondary)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
    }
}
