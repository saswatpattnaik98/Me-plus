import SwiftUI
import AVFoundation

struct TaskCompletionCelebrationView: View {
    let taskName: String
    let isFirstTaskOfDay: Bool
    let currentStreak: Int
    @Binding var isPresented: Bool
    
    @State private var animateGlow = false
    @State private var animateParticles = false
    @State private var animateScale = false
    @State private var animateCheckmark = false
    @State private var animateText = false
    @State private var animateStreak = false
    @State private var backgroundOpacity = 0.0
    @State private var confettiTrigger = 0
    @State private var glowIntensity = 0.0
    @State private var rippleEffect = false
    
    // Haptic feedback generators
    private let impactGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    // Sound player
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        ZStack {
            // Premium dark background with subtle gradient
            LinearGradient(
                colors: [
                    Color.black.opacity(0.95),
                    Color(.systemGray6).opacity(0.3),
                    Color.black.opacity(0.98)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .opacity(backgroundOpacity)
            .animation(.easeInOut(duration: 0.6), value: backgroundOpacity)
            .ignoresSafeArea()
            
            // Subtle radial glow effect
            RadialGradient(
                colors: [
                    Color.green.opacity(glowIntensity * 0.1),
                    Color.clear
                ],
                center: .center,
                startRadius: 50,
                endRadius: 300
            )
            .opacity(glowIntensity)
            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: glowIntensity)
            .ignoresSafeArea()
            
            // Particle effects (minimal for dark mode)
            PremiumParticleEffect(trigger: confettiTrigger)
            
            // Main content
            VStack(spacing: 40) {
                Spacer()
                
                // Premium checkmark with ripple effect
                ZStack {
                    // Ripple effect
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .stroke(Color.green.opacity(0.3), lineWidth: 2)
                            .frame(width: 80 + CGFloat(index * 20), height: 80 + CGFloat(index * 20))
                            .scaleEffect(rippleEffect ? 1.5 : 0.8)
                            .opacity(rippleEffect ? 0.0 : 0.8)
                            .animation(
                                .easeOut(duration: 1.0)
                                .delay(Double(index) * 0.2)
                                .repeatForever(autoreverses: false),
                                value: rippleEffect
                            )
                    }
                    
                    // Main completion circle with glassmorphism
                    ZStack {
                        // Outer glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.green.opacity(0.3),
                                        Color.green.opacity(0.1),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 20,
                                    endRadius: 60
                                )
                            )
                            .frame(width: 120, height: 120)
                            .scaleEffect(animateGlow ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: animateGlow)
                        
                        // Glass morphism circle
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.green.opacity(0.8),
                                                Color.green.opacity(0.6)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.3),
                                                Color.clear
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                            .frame(width: 80, height: 80)
                            .scaleEffect(animateScale ? 1.0 : 0.3)
                            .animation(.spring(response: 0.8, dampingFraction: 0.6), value: animateScale)
                        
                        // Checkmark with premium styling
                        Image(systemName: "checkmark")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.white, Color.white.opacity(0.9)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .scaleEffect(animateCheckmark ? 1.0 : 0.2)
                            .opacity(animateCheckmark ? 1.0 : 0.0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.4), value: animateCheckmark)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    }
                }
                
                // Premium text section
                VStack(spacing: 20) {
                    if isFirstTaskOfDay {
                        // First task celebration
                        VStack(spacing: 12) {
                            Text("✨ First Task Complete ✨")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color.yellow.opacity(0.9),
                                            Color.orange.opacity(0.8)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .scaleEffect(animateText ? 1.0 : 0.5)
                                .opacity(animateText ? 1.0 : 0.0)
                                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.6), value: animateText)
                            
                            Text("Great start to your day!")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                                .scaleEffect(animateText ? 1.0 : 0.5)
                                .opacity(animateText ? 1.0 : 0.0)
                                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.8), value: animateText)
                        }
                    } else {
                        Text("Task Complete")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .scaleEffect(animateText ? 1.0 : 0.5)
                            .opacity(animateText ? 1.0 : 0.0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.6), value: animateText)
                    }
                    
                    // Task name with premium styling
                    Text(taskName)
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        )
                        .scaleEffect(animateText ? 1.0 : 0.5)
                        .opacity(animateText ? 1.0 : 0.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(1.0), value: animateText)
                }
                
                // Premium streak display
                if currentStreak > 1 {
                    PremiumStreakView(streak: currentStreak, animate: $animateStreak)
                        .scaleEffect(animateStreak ? 1.0 : 0.3)
                        .opacity(animateStreak ? 1.0 : 0.0)
                        .animation(.spring(response: 0.7, dampingFraction: 0.7).delay(1.2), value: animateStreak)
                }
                
                Spacer()
                
                // Premium continue button
                Button(action: {
                    closeWithAnimation()
                }) {
                    HStack(spacing: 12) {
                        Text("Tap to Continue")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundStyle(.gray)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
//                    .background(
//                        ZStack {
//                            // Subtle gradient background
//                            RoundedRectangle(cornerRadius: 28)
//                                .fill(
//                                    LinearGradient(
//                                        colors: [
//                                            Color.white.opacity(0.15),
//                                            Color.white.opacity(0.08)
//                                        ],
//                                        startPoint: .topLeading,
//                                        endPoint: .bottomTrailing
//                                    )
//                                )
//                            
//                            // Glass effect
//                            RoundedRectangle(cornerRadius: 28)
//                                .fill(.ultraThinMaterial)
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 28)
//                                        .stroke(
//                                            LinearGradient(
//                                                colors: [
//                                                    Color.white.opacity(0.3),
//                                                    Color.white.opacity(0.1)
//                                                ],
//                                                startPoint: .topLeading,
//                                                endPoint: .bottomTrailing
//                                            ),
//                                            lineWidth: 1
//                                        )
//                                )
//                        }
//                    )
                }
                .scaleEffect(animateText ? 1.0 : 0.5)
                .opacity(animateText ? 1.0 : 0.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(1.4), value: animateText)
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            startPremiumCelebrationSequence()
        }
        .onTapGesture {
            // Quick dismiss on tap anywhere
            closeWithAnimation()
        }
    }
    
    private func startPremiumCelebrationSequence() {
        // Premium haptic sequence
        impactGenerator.impactOccurred()
        
        // Play refined completion sound
        playPremiumCompletionSound()
        
        // Staggered animation sequence
        backgroundOpacity = 1.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                animateScale = true
            }
            glowIntensity = 1.0
            rippleEffect = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                animateCheckmark = true
            }
            // Success haptic
            notificationGenerator.notificationOccurred(.success)
            confettiTrigger += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animateText = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) {
                animateStreak = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeInOut(duration: 0.8)) {
                animateGlow = true
            }
        }
    }
    
    private func playPremiumCompletionSound() {
        // Try custom sound first, fallback to refined system sound
        if let soundURL = Bundle.main.url(forResource: "premium_success", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.volume = 0.4 // Subtle volume for premium feel
                audioPlayer?.play()
            } catch {
                // Use a more subtle system sound
                AudioServicesPlaySystemSound(1103) // More refined success sound
            }
        } else {
            AudioServicesPlaySystemSound(1103)
        }
    }
    
    private func closeWithAnimation() {
        // Gentle haptic feedback
        let lightImpact = UIImpactFeedbackGenerator(style: .light)
        lightImpact.impactOccurred()
        
        withAnimation(.easeInOut(duration: 0.4)) {
            backgroundOpacity = 0.0
            animateScale = false
            animateText = false
            glowIntensity = 0.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            isPresented = false
        }
    }
}

// MARK: - Premium Streak View
struct PremiumStreakView: View {
    let streak: Int
    @Binding var animate: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.orange, Color.red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("\(streak) Day Streak!")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule()
                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Premium Particle Effect
struct PremiumParticleEffect: View {
    let trigger: Int
    @State private var particles: [ParticleData] = []
    
    var body: some View {
        ZStack {
            ForEach(particles, id: \.id) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .opacity(particle.opacity)
            }
        }
        .onChange(of: trigger) { _ in
            createPremiumParticles()
        }
    }
    
    private func createPremiumParticles() {
        let colors: [Color] = [.green, .white, .yellow.opacity(0.8)]
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        // Clear existing particles
        particles.removeAll()
        
        for _ in 0..<15 { // Fewer, more refined particles
            let particle = ParticleData(
                id: UUID(),
                position: CGPoint(
                    x: CGFloat.random(in: 50...(screenWidth - 50)),
                    y: CGFloat.random(in: (screenHeight * 0.3)...(screenHeight * 0.7))
                ),
                color: colors.randomElement() ?? .white,
                size: CGFloat.random(in: 3...8),
                opacity: Double.random(in: 0.4...0.8)
            )
            particles.append(particle)
        }
        
        // Animate and remove particles
        withAnimation(.easeOut(duration: 2.0)) {
            for i in particles.indices {
                // Fixed: Changed the range from -100...(-200) to -200...(-100)
                particles[i].position.y += CGFloat.random(in: -200...(-100))
                particles[i].position.x += CGFloat.random(in: -50...50)
                particles[i].opacity = 0.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            particles.removeAll()
        }
    }
}
// MARK: - Preview
struct TaskCompletionCelebrationView_Previews: PreviewProvider {
    static var previews: some View {
        TaskCompletionCelebrationView(
            taskName: "Complete morning workout",
            isFirstTaskOfDay: true,
            currentStreak: 5,
            isPresented: .constant(true)
        )
        .preferredColorScheme(.dark)
    }
}
