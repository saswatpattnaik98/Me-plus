//
//  AddButtonView.swift
//  Me+
//
//  Created by Hari's Mac on 03.06.2025.
//

import SwiftUI

struct AddButtonView: View {
    let showEditHabit: Bool
    let backgroundGlow: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(.indigo.opacity(0.2))
                    .frame(width: 70, height: 70)
                    .scaleEffect(backgroundGlow ? 1.2 : 1.0)
                
                Circle()
                    .fill(.indigo)
                    .frame(width: 58, height: 58)
                    .shadow(color: .indigo.opacity(0.3), radius: 8, x: 0, y: 4)
                    .overlay(
                        Circle()
                            .strokeBorder(.white.opacity(0.3), lineWidth: 2)
                    )
                
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                    .symbolEffect(.bounce, value: showEditHabit)
            }
        }
    }
}
