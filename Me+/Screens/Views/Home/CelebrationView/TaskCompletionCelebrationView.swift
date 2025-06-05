//
//  TaskCompletionCelebrationView.swift
//  Me+
//
//  Created by Hari's Mac on 04.06.2025.


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
    
    // Haptic feedback generators
    private let impactGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    // Sound player
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                colors: [
                    Color.purple.opacity(0.8),
                    Color.blue.opacity(0.6),
                    Color.teal.opacity(0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .opacity(backgroundOpacity)
            .animation(.easeInOut(duration: 0.5), value: backgroundOpacity)
            .ignoresSafeArea()
            
            // Particle effects
            ParticleEffect(trigger: confettiTrigger)
            
            // Main content
            VStack(spacing: 30) {
                Spacer()
                
                // Checkmark animation
                ZStack {
                    // Glowing circle
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 30,
                                endRadius: animateGlow ? 80 : 40
                            )
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(animateScale ? 1.2 : 0.8)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: animateGlow)
                    
                    // Main circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.green, Color.teal],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .scaleEffect(animateScale ? 1.0 : 0.6)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animateScale)
                    
                    // Checkmark
                    Image(systemName: "checkmark")
                        .font(.system(size: 35, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(animateCheckmark ? 1.0 : 0.5)
                        .opacity(animateCheckmark ? 1.0 : 0.0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.3), value: animateCheckmark)
                }
                
                // Task completion message
                VStack(spacing: 15) {
                    if isFirstTaskOfDay {
                        Text("🎉 Congratulations! 🎉")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.yellow, .orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .scaleEffect(animateText ? 1.0 : 0.8)
                            .opacity(animateText ? 1.0 : 0.0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.5), value: animateText)
                        
                        Text("You've completed your first task of the day!")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .scaleEffect(animateText ? 1.0 : 0.8)
                            .opacity(animateText ? 1.0 : 0.0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.7), value: animateText)
                    } else {
                        Text("Task Completed! ✨")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .scaleEffect(animateText ? 1.0 : 0.8)
                            .opacity(animateText ? 1.0 : 0.0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.5), value: animateText)
                    }
                    
                    Text("\(taskName)")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .scaleEffect(animateText ? 1.0 : 0.8)
                        .opacity(animateText ? 1.0 : 0.0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.9), value: animateText)
                }
                
                // Streak animation (if applicable)
                if currentStreak > 1 {
                    StreakAnimationView(streak: currentStreak, animate: $animateStreak)
                        .scaleEffect(animateStreak ? 1.0 : 0.5)
                        .opacity(animateStreak ? 1.0 : 0.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(1.1), value: animateStreak)
                }
                
                Spacer()
                
                // Close button
                Button(action: {
                    closeWithAnimation()
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                        Text("Continue")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .scaleEffect(animateText ? 1.0 : 0.8)
                .opacity(animateText ? 1.0 : 0.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(1.3), value: animateText)
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            startCelebrationSequence()
        }
    }
    
    private func startCelebrationSequence() {
        // Initial haptic feedback
        impactGenerator.impactOccurred()
        
        // Play sound effect
        playCompletionSound()
        
        // Start animation sequence
        withAnimation(.easeInOut(duration: 0.3)) {
            backgroundOpacity = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                animateScale = true
                animateGlow = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation {
                animateCheckmark = true
            }
            // Second haptic feedback
            notificationGenerator.notificationOccurred(.success)
            confettiTrigger += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                animateText = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            withAnimation {
                animateStreak = true
            }
        }
    }
    
    private func playCompletionSound() {
        // Create a simple success tone using system sounds
        // You can replace this with custom audio files
        if let soundURL = Bundle.main.url(forResource: "success_tone", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.volume = 0.5
                audioPlayer?.play()
            } catch {
                print("Error playing sound: \(error)")
                // Fallback to system sound
                AudioServicesPlaySystemSound(1016) // Success sound
            }
        } else {
            // Use system sound as fallback
            AudioServicesPlaySystemSound(1016) // Success sound
        }
    }
    
    private func closeWithAnimation() {
        impactGenerator.impactOccurred()
        
        withAnimation(.easeInOut(duration: 0.3)) {
            backgroundOpacity = 0.0
            animateScale = false
            animateText = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPresented = false
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
    }
}
