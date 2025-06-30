////
////  ParticleEffect.swift
////  Me+
////
////  Created by Hari's Mac on 04.06.2025.
////
//
//import SwiftUI
//
//
//// MARK: - Particle Effect View
//struct ParticleEffect: View {
//    let trigger: Int
//    
//    @State private var particles: [ParticleData] = []
//    
//    var body: some View {
//        ZStack {
//            ForEach(particles, id: \.id) { particle in
//                Circle()
//                    .fill(particle.color)
//                    .frame(width: particle.size, height: particle.size)
//                    .position(particle.position)
//                    .opacity(particle.opacity)
//            }
//        }
//        .onChange(of: trigger) { _, _ in
//            createParticles()
//        }
//    }
//    
//    private func createParticles() {
//        let colors: [Color] = [.yellow, .orange, .pink, .purple, .blue, .teal, .green]
//        
//        for _ in 0..<30 {
//            let particle = ParticleData(
//                id: UUID(),
//                position: CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2),
//                color: colors.randomElement() ?? .yellow,
//                size: Double.random(in: 4...12),
//                opacity: 1.0
//            )
//            particles.append(particle)
//        }
//        
//        // Animate particles
//        withAnimation(.easeOut(duration: 2.0)) {
//            for i in particles.indices {
//                let angle = Double.random(in: 0...2 * .pi)
//                let distance = Double.random(in: 100...300)
//                
//                particles[i].position.x += CGFloat(cos(angle) * distance)
//                particles[i].position.y += CGFloat(sin(angle) * distance)
//                particles[i].opacity = 0.0
//                particles[i].size *= 0.5
//            }
//        }
//        
//        // Remove particles after animation
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//            particles.removeAll()
//        }
//    }
//}
