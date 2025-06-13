//
//  EditTaskBG.swift
//  Me+
//
//  Created by Hari's Mac on 05.06.2025.
//

import SwiftUI

struct EditTaskBG: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color.mint.opacity(0.3),
                Color.cyan.opacity(0.2),
                Color.white.opacity(0.8)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}
