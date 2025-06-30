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
                Color.indigo.opacity(0.3),
                Color.purple.opacity(0.2),
                Color.black.opacity(0.8)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}
