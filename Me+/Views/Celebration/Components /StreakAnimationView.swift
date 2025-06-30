////
////  StreakAnimationView.swift
////  Me+
////
////  Created by Hari's Mac on 04.06.2025.
////
//
//import SwiftUI
//
//// MARK: - Streak Animation View
//struct StreakAnimationView: View {
//    let streak: Int
//    @Binding var animate: Bool
//    
//    @State private var fireAnimation = false
//    
//    var body: some View {
//        VStack(spacing: 10) {
//            HStack(spacing: 5) {
//                Image(systemName: "flame.fill")
//                    .font(.title2)
//                    .foregroundStyle(
//                        LinearGradient(
//                            colors: [.red, .orange, .yellow],
//                            startPoint: .bottom,
//                            endPoint: .top
//                        )
//                    )
//                    .scaleEffect(fireAnimation ? 1.2 : 1.0)
//                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: fireAnimation)
//                
//                Text("\(streak) Day Streak!")
//                    .font(.title3)
//                    .fontWeight(.bold)
//                    .foregroundStyle(
//                        LinearGradient(
//                            colors: [.orange, .yellow],
//                            startPoint: .leading,
//                            endPoint: .trailing
//                        )
//                    )
//            }
//            
//            Text("Keep up the momentum!")
//                .font(.subheadline)
//                .foregroundColor(.white.opacity(0.8))
//        }
//        .padding(.horizontal, 20)
//        .padding(.vertical, 12)
//        .background(
//            RoundedRectangle(cornerRadius: 20)
//                .fill(.ultraThinMaterial)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 20)
//                        .stroke(Color.orange.opacity(0.5), lineWidth: 1)
//                )
//        )
//        .onChange(of: animate) { _, newValue in
//            if newValue {
//                fireAnimation = true
//            }
//        }
//    }
//}
