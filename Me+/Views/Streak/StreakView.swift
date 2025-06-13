import SwiftUI

struct StreakExpandView: View {
    @Binding var streakCount: Int
    @State private var animateFlame = false
    @State private var animateCounter = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Dynamic background based on streak
                backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Spacer()
                    
                    // Header section
                    VStack(spacing: 16) {
                        // Flame icon with animation
                        flameIcon
                        
                        // Streak counter with enhanced styling
                        streakCounter
                        
                        // Motivational text
                        streakText
                    }
                    
                    Spacer()
                    
                    // Progress section (optional enhancement)
                    if streakCount > 0 {
                        progressSection
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    // MARK: - Background
    private var backgroundGradient: some View {
        Group {
            if streakCount > 0 {
                // Active streak gradient
                LinearGradient(
                    colors: streakCount >= 7 ?
                        [Color.orange, Color.red.opacity(0.8), Color.yellow.opacity(0.3)] :
                        [Color.orange.opacity(0.8), Color.yellow.opacity(0.4), Color.white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                // No streak - subtle gray gradient
                LinearGradient(
                    colors: [Color.gray.opacity(0.2), Color.white],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
    }
    
    // MARK: - Flame Icon
    private var flameIcon: some View {
        ZStack {
            // Glow effect for active streaks
            if streakCount > 0 {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.orange.opacity(0.4), Color.clear],
                            center: .center,
                            startRadius: 5,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .opacity(animateFlame ? 0.8 : 0.4)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateFlame)
            }
            
            // Main flame image
            Image(streakCount > 0 ? "flame" : "flamedull")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .scaleEffect(animateFlame ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animateFlame)
        }
    }
    
    // MARK: - Streak Counter
    private var streakCounter: some View {
        VStack(spacing: 8) {
            // Enhanced counter with background
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: streakCount > 0 ? [.orange, .red] : [.gray.opacity(0.3)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .frame(height: 80)
                
                HStack {
                    Text("\(streakCount)")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: streakCount > 0 ? [.orange, .red] : [.gray],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .scaleEffect(animateCounter ? 1.1 : 1.0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: animateCounter)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Streak Text
    private var streakText: some View {
        VStack(spacing: 4) {
            Text(streakCount == 1 ? "day streak" : "day streak")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(streakCount > 0 ? .orange : .gray)
            
            if streakCount > 0 {
                Text(motivationalMessage)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
    }
    
    // MARK: - Progress Section
    private var progressSection: some View {
        VStack(spacing: 16) {
            // Progress toward next milestone
            let nextMilestone = getNextMilestone(for: streakCount)
            let progress = Double(streakCount) / Double(nextMilestone)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Next milestone")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(nextMilestone) days")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.orange)
                }
                
                ProgressView(value: progress)
                    .tint(.orange)
                    .background(.ultraThinMaterial, in: Capsule())
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }
    
    // MARK: - Helper Methods
    private var motivationalMessage: String {
        switch streakCount {
        case 1:
            return "Great start! Keep it going! 🚀"
        case 2...6:
            return "You're building momentum! 💪"
        case 7...13:
            return "One week strong! Fantastic! ⭐"
        case 14...29:
            return "Two weeks of dedication! 🔥"
        case 30...99:
            return "Monthly master! You're unstoppable! 🏆"
        case 100...:
            return "Century achiever! Legendary! 👑"
        default:
            return "Ready to start your journey? 🌟"
        }
    }
    
    private func getNextMilestone(for count: Int) -> Int {
        let milestones = [7, 14, 30, 50, 100, 200, 365]
        return milestones.first { $0 > count } ?? (count + 50)
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 0.8).delay(0.2)) {
            animateCounter = true
        }
        
        withAnimation(.easeInOut(duration: 1.2).delay(0.5)) {
            animateFlame = true
        }
    }
}

#Preview("Active Streak") {
    StreakExpandView(streakCount: .constant(15))
}

#Preview("No Streak") {
    StreakExpandView(streakCount: .constant(0))
}

#Preview("Long Streak") {
    StreakExpandView(streakCount: .constant(45))
}
