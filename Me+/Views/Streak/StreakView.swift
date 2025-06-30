import SwiftUI

struct StreakExpandView: View {
    @Binding var streakCount: Int
    @State private var animateFlame = false
    @State private var animateCounter = false
    @State private var animateGlow = false
    @State private var showContent = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Clean dark background
                Color.black
                    .ignoresSafeArea()
                
                // Subtle animated background pattern
                backgroundPattern
                
                ScrollView{
                    VStack(spacing: 32) {
                        Spacer(minLength: 40)
                        
                        // Main content card
                        mainContentCard
                        
                        // Progress section
                        if streakCount > 0 {
                            progressCard
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                }
                .scrollIndicators(.hidden)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    // MARK: - Background Pattern
    private var backgroundPattern: some View {
        ZStack {
            // Subtle grid pattern
            if streakCount > 0 {
                VStack(spacing: 60) {
                    ForEach(0..<10, id: \.self) { _ in
                        HStack(spacing: 60) {
                            ForEach(0..<6, id: \.self) { _ in
                                Circle()
                                    .fill(Color.indigo.opacity(0.03))
                                    .frame(width: 2, height: 2)
                            }
                        }
                    }
                }
                .opacity(animateGlow ? 0.6 : 0.2)
                .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: animateGlow)
            }
        }
    }
    
    // MARK: - Main Content Card
    private var mainContentCard: some View {
        VStack(spacing: 28) {
            // Header
            headerSection
            
            // Flame icon
            flameIcon
            
            // Counter
            streakCounter
            
            // Description
            streakDescription
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 36)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemGray6).opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            Color.indigo.opacity(streakCount > 0 ? 0.3 : 0.1),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: streakCount > 0 ? Color.indigo.opacity(0.1) : Color.clear,
                    radius: 20,
                    x: 0,
                    y: 10
                )
        )
        .scaleEffect(showContent ? 1.0 : 0.95)
        .opacity(showContent ? 1.0 : 0)
        .animation(.spring(response: 0.8, dampingFraction: 0.8), value: showContent)
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("STREAK")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(Color.indigo.opacity(streakCount > 0 ? 0.8 : 0.4))
                .tracking(3)
            
            Rectangle()
                .fill(Color.indigo.opacity(streakCount > 0 ? 0.3 : 0.1))
                .frame(width: 40, height: 2)
                .cornerRadius(1)
        }
    }
    
    // MARK: - Flame Icon
    private var flameIcon: some View {
        ZStack {
            // Outer glow
            if streakCount > 0 {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.indigo.opacity(0.15),
                                Color.indigo.opacity(0.05),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 30,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .scaleEffect(animateGlow ? 1.1 : 0.9)
                    .opacity(animateGlow ? 0.8 : 0.4)
                    .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: animateGlow)
            }
            
            // Inner glow
            if streakCount > 0 {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.indigo.opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 50
                        )
                    )
                    .frame(width: 100, height: 100)
                    .opacity(animateFlame ? 0.6 : 0.3)
                    .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: animateFlame)
            }
            
            // Flame icon
            ZStack {
                // Background circle for inactive state
                if streakCount == 0 {
                    Circle()
                        .fill(Color(.systemGray5).opacity(0.3))
                        .frame(width: 80, height: 80)
                }
                
                Image(systemName: streakCount > 0 ? "flame.fill" : "flame")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundColor(
                        streakCount > 0 ?
                        Color.indigo :
                        Color(.systemGray3)
                    )
                    .scaleEffect(animateFlame ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateFlame)
            }
        }
    }
    
    // MARK: - Streak Counter
    private var streakCounter: some View {
        VStack(spacing: 16) {
            // Main counter
            HStack(spacing: 8) {
                Text("\(streakCount)")
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    .foregroundColor(
                        streakCount > 0 ?
                        Color.indigo :
                        Color(.systemGray3)
                    )
                    .scaleEffect(animateCounter ? 1.02 : 1.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animateCounter)
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6).opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                Color.indigo.opacity(streakCount > 0 ? 0.2 : 0.05),
                                lineWidth: 1
                            )
                    )
            )
            
            // Days label
            Text(streakCount == 1 ? "day" : "days")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(Color.indigo.opacity(streakCount > 0 ? 0.7 : 0.4))
                .tracking(1)
        }
    }
    
    // MARK: - Streak Description
    private var streakDescription: some View {
        Group {
            if streakCount > 0 {
                VStack(spacing: 12) {
                    Text(motivationalMessage)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.primary.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    // Achievement badge
                    HStack(spacing: 8) {
                        Image(systemName: achievementIcon)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.indigo)
                        
                        Text(achievementText)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(Color.indigo.opacity(0.8))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.indigo.opacity(0.1))
                            .overlay(
                                Capsule()
                                    .stroke(Color.indigo.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
            } else {
                EmptyView()
            }
        }
    }
    
    // MARK: - Progress Card
    private var progressCard: some View {
        let nextMilestone = getNextMilestone(for: streakCount)
        let progress = Double(streakCount) / Double(nextMilestone)
        
        return VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Next Milestone")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text("\(nextMilestone) days")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(Color.indigo)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(nextMilestone - streakCount) days left")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color.indigo)
                }
            }
            
            // Progress bar
            VStack(spacing: 8) {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray6).opacity(0.3))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.indigo)
                        .frame(width: max(12, progress * (UIScreen.main.bounds.width - 88)), height: 6)
                        .animation(.easeOut(duration: 1.5).delay(0.5), value: progress)
                }
                
                HStack {
                    Text("0")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(nextMilestone)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6).opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.indigo.opacity(0.2), lineWidth: 1)
                )
        )
        .scaleEffect(showContent ? 1.0 : 0.95)
        .opacity(showContent ? 1.0 : 0)
        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2), value: showContent)
    }
    
    // MARK: - Helper Properties
    private var motivationalMessage: String {
        switch streakCount {
        case 1:
            return "Great start! Keep the momentum going."
        case 2...6:
            return "Building a solid foundation."
        case 7...13:
            return "One week strong! You're on fire."
        case 14...29:
            return "Two weeks of consistency!"
        case 30...49:
            return "Monthly achiever! Outstanding work."
        case 50...99:
            return "Halfway to 100! You're unstoppable."
        case 100...:
            return "Century club! Absolutely legendary."
        default:
            return "Ready to begin your streak?"
        }
    }
    
    private var achievementIcon: String {
        switch streakCount {
        case 1...6: return "star.fill"
        case 7...13: return "crown.fill"
        case 14...29: return "medal.fill"
        case 30...49: return "trophy.fill"
        case 50...99: return "rosette"
        case 100...: return "diamond.fill"
        default: return "star"
        }
    }
    
    private var achievementText: String {
        switch streakCount {
        case 1...6: return "Getting Started"
        case 7...13: return "Week Warrior"
        case 14...29: return "Consistency King"
        case 30...49: return "Monthly Master"
        case 50...99: return "Streak Legend"
        case 100...: return "Hall of Fame"
        default: return "Ready to Start"
        }
    }
    
    private func getNextMilestone(for count: Int) -> Int {
        let milestones = [7, 14, 30, 50, 100, 200, 365, 500, 1000]
        return milestones.first { $0 > count } ?? (count + 100)
    }
    
    private func startAnimations() {
        withAnimation(.easeOut(duration: 0.6)) {
            showContent = true
        }
        
        withAnimation(.easeInOut(duration: 1.0).delay(0.8)) {
            animateCounter = true
        }
        
        withAnimation(.easeInOut(duration: 1.5).delay(1.0)) {
            animateFlame = true
        }
        
        withAnimation(.easeInOut(duration: 2.0).delay(1.2)) {
            animateGlow = true
        }
    }
}

#Preview("Active Streak") {
    StreakExpandView(streakCount: .constant(15))
        .preferredColorScheme(.dark)
}

#Preview("No Streak") {
    StreakExpandView(streakCount: .constant(0))
        .preferredColorScheme(.dark)
}

#Preview("Long Streak") {
    StreakExpandView(streakCount: .constant(45))
        .preferredColorScheme(.dark)
}
