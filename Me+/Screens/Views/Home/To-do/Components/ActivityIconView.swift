//
//  ActivityIconView.swift
//  Me+
//
//  Created by Hari's Mac on 03.06.2025.
//

import SwiftUI

struct ActivityIconView: View {
    let activity: Activity
    let isNewTask: Bool
    
    var body: some View {
        Group {
            if let uiImage = UIImage(named: activity.name) {
                Image(uiImage: uiImage)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .scaledToFit()
            } else {
                Image("default")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .scaledToFit()
            }
        }
        .scaleEffect(isNewTask ? 1.2 : 1.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isNewTask)
    }
}
