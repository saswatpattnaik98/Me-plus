import SwiftUI

struct PlaceholderView: View {
    @State private var isAnimating = false
    @State private var breathingScale = 1.0
    @State private var floatingOffset: CGFloat = 0
    @State private var tipIndex = 0
    
    // Animation timer for tip rotation
    let timer = Timer.publish(every: 4.0, on: .main, in: .common).autoconnect()
    
    // Tips array for subtle text animation
    private let tips = ["1.⁠ ⁠More on Mon, Tue, Wed",
                        "2.⁠ ⁠More in morning than evening",
                        "3.⁠ ⁠⁠Definitely set time for rest"]
    
    var body: some View {
        VStack(spacing: 16) {
            // Animated image with multiple subtle effects
            ZStack {
                // Subtle pulsing background circle
                Circle()
                    .fill(.clear)
                    .frame(width: 220, height: 220)
                    .overlay(
                        Circle()
                            .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                            .scaleEffect(breathingScale)
                    )
                
                Image("noHabits")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .opacity(0.8)
                    .scaleEffect(breathingScale)
                    .offset(y: floatingOffset)
                    .rotationEffect(.degrees(isAnimating ? 2 : -2))
            }
            .onAppear {
//                // Staggered animation start
//                withAnimation(.easeInOut(duration: 0.8)) {
//                    opacity = 1
//                }
                
                // Gentle breathing animation
                withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                    breathingScale = 1.05
                }
                
                // Subtle floating animation
                withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                    floatingOffset = -8
                }
                
                // Very subtle rotation
                withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
            
            // Animated title with gentle slide-in
            Text("Top athletes follow 'Top Heaviness'")
                .font(.system(size: 15))
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .onTapGesture {
                    // Easter egg: gentle bounce on tap
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        breathingScale = 1.1
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            breathingScale = 1.05
                        }
                    }
                }
            
            // Animated tips with subtle transitions
            VStack(spacing: 4) {
                Text(tips[tipIndex])
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    .id("tip-\(tipIndex)") // Force view refresh for transitions
                
                // Subtle dots indicator
                HStack(spacing: 6) {
                    ForEach(0..<tips.count, id: \.self) { index in
                        Circle()
                            .fill(index == tipIndex ? Color.gray.opacity(0.6) : Color.gray.opacity(0.2))
                            .frame(width: 4, height: 4)
                            .scaleEffect(index == tipIndex ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: tipIndex)
                    }
                }
                .padding(.top, 8)
            }
            .onReceive(timer) { _ in
                withAnimation(.easeInOut(duration: 0.5)) {
                    tipIndex = (tipIndex + 1) % tips.count
                }
            }
        }
        .padding()
        // Subtle parallax effect on drag (if user swipes)
        .offset(y: floatingOffset * 0.1)
        .gesture(
            DragGesture()
                .onChanged { value in
                    withAnimation(.interactiveSpring()) {
                        floatingOffset = value.translation.width * 0.1
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        floatingOffset = -8 // Return to floating animation
                    }
                }
        )
    }
}

#Preview {
    PlaceholderView()
}
