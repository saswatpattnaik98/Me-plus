//
//  SwipeActionsView.swift
//  Me+
//
//  Created by Hari's Mac on 03.06.2025.
//

import SwiftUI

struct SwipeActionsView: View {
    let activity: Activity
    let onDeleteSingle: () -> Void
    let onDeleteAll: () -> Void
    
    var body: some View {
        Group {
            if activity.isRepeating {
                Button(action: onDeleteAll) {
                    VStack(spacing: 4) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Delete All")
                            .font(.system(size: 10, weight: .medium))
                    }
                }
                .tint(.orange)
                
                Button(action: onDeleteSingle) {
                    VStack(spacing: 4) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Delete")
                            .font(.system(size: 10, weight: .medium))
                    }
                }
                .tint(.red)
            } else {
                Button(action: onDeleteSingle) {
                    VStack(spacing: 4) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Delete")
                            .font(.system(size: 10, weight: .medium))
                    }
                }
                .tint(.red)
            }
        }
    }
}
