//
//  ConfettiView.swift
//  Me+
//
//  Created by Hari's Mac on 05.06.2025.
//

import SwiftUI
// MARK: - Confetti View
struct ConfettiView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<50, id: \.self) { _ in
                Circle()
                    .fill(Color.random)
                    .frame(width: 8, height: 8)
                    .offset(
                        x: animate ? .random(in: -200...200) : 0,
                        y: animate ? .random(in: -400...400) : 0
                    )
                    .opacity(animate ? 0 : 1)
                    .animation(
                        .easeOut(duration: 2)
                        .delay(.random(in: 0...0.5)),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

extension Color {
    static var random: Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}
