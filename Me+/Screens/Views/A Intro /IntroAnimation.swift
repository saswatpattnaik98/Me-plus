import SwiftUI

struct IntroAnimation: View {
    @State private var centerIndex = 0

        let images = [
            "checkmark.circle.fill",
            "flame.fill",
            "calendar",
            "star.fill",
            "timer"
        ]

        let positions: [CGSize] = [
            CGSize(width: 0, height: -130), // Top
            CGSize(width: -120, height: 0), // Left
            CGSize(width: 0, height: 0),    // Center
            CGSize(width: 120, height: 0),  // Right
            CGSize(width: 0, height: 120)   // Bottom
        ]
    
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

        var body: some View {
            ZStack {
                ForEach(0..<5, id: \.self) { index in
                    let isCenter = index == centerIndex

                    Image(systemName: images[index])
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(20)
                        .frame(width: isCenter ? 70 : 70,
                               height: isCenter ? 70 : 70)
                    
                        .background(
                            RoundedRectangle(cornerRadius: 25, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.green.opacity(0.9),
                                           // Color.opacity(0.9)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                                        .stroke(Color.white, lineWidth: isCenter ? 4 : 0)
                                )
                                .shadow(color: .green.opacity(0.4), radius: 10, x: 0, y: 5)
                        )
                        .foregroundStyle(Color.white.opacity(0.8))
                        .scaleEffect(isCenter ? 1.2 : 1.0)
                        .offset(positions[(index - centerIndex + 5) % 5])
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: centerIndex)
                }
            }
            .frame(width: 300, height: 300)
            .onReceive(timer) { _ in
                centerIndex = (centerIndex + 1) % 5
            }
        }
}
#Preview {
    IntroAnimation()
}

