import SwiftUI

struct StreakExpandView: View {
    @Binding var streakCount: Int
    @State private var animateFlame = false
    @State private var animateCounter = false
    @State private var animateBackground = false
    @State private var showParticles = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Premium background with animated elements
                backgroundGradient
                    .ignoresSafeArea()
                
                // Animated floating particles for premium feel
                if streakCount > 0 {
                    floatingParticles
                }
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Main content container with glass morphism
                    VStack(spacing: 40) {
                        // Header section with enhanced styling
                        headerSection
                        
                        // Streak counter with premium design
                        streakCounter
                        
                        // Motivational text with better typography
                        streakText
                        
                        // Progress section with enhanced visuals
                        if streakCount > 0 {
                            progressSection
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.vertical, 40)
                    .background(
                        RoundedRectangle(cornerRadius: 32)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 32)
                                    .stroke(
                                        LinearGradient(
                                            colors: streakCount > 0 ?
                                                [Color.blue.opacity(0.3), Color.purple.opacity(0.3)] :
                                                [Color.gray.opacity(0.2)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                            .shadow(color: .black.opacity(0.05), radius: 20, x: 0, y: 10)
                    )
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    // MARK: - Premium Background
    private var backgroundGradient: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: streakCount > 0 ?
                    [Color.blue.opacity(0.1), Color.purple.opacity(0.05), Color.cyan.opacity(0.08)] :
                    [Color.gray.opacity(0.05), Color.white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Animated gradient overlay
            if streakCount > 0 {
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.1),
                        Color.purple.opacity(0.05),
                        Color.cyan.opacity(0.08),
                        Color.blue.opacity(0.1)
                    ],
                    startPoint: animateBackground ? .topLeading : .bottomTrailing,
                    endPoint: animateBackground ? .bottomTrailing : .topLeading
                )
                .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: animateBackground)
            }
        }
    }
    
    // MARK: - Floating Particles
    private var floatingParticles: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: CGFloat.random(in: 4...12))
                    .offset(
                        x: CGFloat.random(in: -150...150),
                        y: CGFloat.random(in: -300...300)
                    )
                    .opacity(showParticles ? 0.6 : 0)
                    .animation(
                        .easeInOut(duration: Double.random(in: 3...6))
                        .repeatForever(autoreverses: true)
                        .delay(Double.random(in: 0...2)),
                        value: showParticles
                    )
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 24) {
            // Enhanced flame icon with premium effects
            flameIcon
            
            // Streak label with modern typography
            Text("STREAK")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: streakCount > 0 ? [.blue, .purple] : [.gray],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .tracking(2)
                .opacity(0.8)
        }
    }
    
    // MARK: - Premium Flame Icon
    private var flameIcon: some View {
        ZStack {
            // Outer glow ring
            if streakCount > 0 {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.blue.opacity(0.2),
                                Color.purple.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(animateFlame ? 1.2 : 0.8)
                    .opacity(animateFlame ? 0.6 : 0.3)
                    .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: animateFlame)
            }
            
            // Inner glow
            if streakCount > 0 {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.orange.opacity(0.3), Color.clear],
                            center: .center,
                            startRadius: 5,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                    .opacity(animateFlame ? 0.8 : 0.4)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateFlame)
            }
            
            // Main flame image with enhanced styling
            Image(streakCount > 0 ? "flame" : "flamedull")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .scaleEffect(animateFlame ? 1.08 : 1.0)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateFlame)
                .shadow(color: streakCount > 0 ? .orange.opacity(0.3) : .clear, radius: 10, x: 0, y: 5)
        }
    }
    
    // MARK: - Premium Streak Counter
    private var streakCounter: some View {
        VStack(spacing: 12) {
            // Enhanced counter with premium styling
            ZStack {
                // Background with glass morphism
                RoundedRectangle(cornerRadius: 28)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(
                                LinearGradient(
                                    colors: streakCount > 0 ?
                                        [Color.blue.opacity(0.4), Color.purple.opacity(0.4)] :
                                        [Color.gray.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 8)
                    .frame(height: 100)
                
                HStack(spacing: 4) {
                    Text("\(streakCount)")
                        .font(.system(size: 56, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: streakCount > 0 ?
                                    [Color.blue, Color.purple, Color.cyan] :
                                    [Color.gray],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .scaleEffect(animateCounter ? 1.15 : 1.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animateCounter)
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Enhanced Streak Text
    private var streakText: some View {
        VStack(spacing: 8) {
            Text(streakCount == 1 ? "day" : "days")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: streakCount > 0 ? [.blue, .purple] : [.gray],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .tracking(1)
            
            if streakCount > 0 {
                Text(motivationalMessage)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.blue.opacity(0.1), lineWidth: 1)
                            )
                    )
            }
        }
    }
    
    // MARK: - Premium Progress Section
    private var progressSection: some View {
        VStack(spacing: 20) {
            // Progress toward next milestone with enhanced design
            let nextMilestone = getNextMilestone(for: streakCount)
            let progress = Double(streakCount) / Double(nextMilestone)
            
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Next Milestone")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                        Text("\(nextMilestone) days")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    
                    Spacer()
                    
                    // Progress percentage
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                
                // Enhanced progress bar
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple, .cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, CGFloat(progress) * UIScreen.main.bounds.width * 0.7), height: 8)
                        .animation(.easeInOut(duration: 1.5), value: progress)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
            )
        }
    }
    
    // MARK: - Helper Methods
    private var motivationalMessage: String {
        switch streakCount {
        case 1:
            return "Amazing start! You're on fire! 🔥"
        case 2...6:
            return "Building momentum like a pro! 💪"
        case 7...13:
            return "Week warrior! You're unstoppable! ⚡"
        case 14...29:
            return "Two weeks of excellence! 🌟"
        case 30...99:
            return "Monthly master! Pure dedication! 🏆"
        case 100...:
            return "Century club! You're legendary! 👑"
        default:
            return "Ready to start your journey? 🌟"
        }
    }
    
    private func getNextMilestone(for count: Int) -> Int {
        let milestones = [7, 14, 30, 50, 100, 200, 365]
        return milestones.first { $0 > count } ?? (count + 50)
    }
    
    private func startAnimations() {
        // Staggered animations for premium feel
        withAnimation(.easeInOut(duration: 1.0).delay(0.3)) {
            animateCounter = true
        }
        
        withAnimation(.easeInOut(duration: 1.5).delay(0.6)) {
            animateFlame = true
        }
        
        withAnimation(.easeInOut(duration: 2.0).delay(0.9)) {
            animateBackground = true
        }
        
        withAnimation(.easeInOut(duration: 1.0).delay(1.2)) {
            showParticles = true
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
