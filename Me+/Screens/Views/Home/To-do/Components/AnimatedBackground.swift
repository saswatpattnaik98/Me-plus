//
//  AnimatedBackground.swift
//  Me+
//
//  Created by Hari's Mac on 03.06.2025.
//

import SwiftUI
struct AnimatedBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color.blue.opacity(0.05),
                Color.purple.opacity(0.05),
                Color.indigo.opacity(0.05)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}
