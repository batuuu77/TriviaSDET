
import SwiftUI
import Foundation
struct BackgroundParticles: View {  // Changed name from ParticleSystem
    let particleCount: Int
    @State private var particles: [Particle] = []
    
    struct Particle: Identifiable {
        let id = UUID()
        var position: CGPoint
        var opacity: Double
    }
    
    var body: some View {
        TimelineView(.animation) { _ in
            Canvas { context, size in
                for particle in particles {
                    context.opacity = particle.opacity
                    context.fill(
                        Circle().path(in: CGRect(x: particle.position.x,
                                               y: particle.position.y,
                                               width: 2,
                                               height: 2)),
                        with: .color(.white)
                    )
                }
            }
        }
        .onAppear {
            particles = (0..<particleCount).map { _ in
                Particle(
                    position: CGPoint(
                        x: .random(in: 0...UIScreen.main.bounds.width),
                        y: .random(in: 0...UIScreen.main.bounds.height)
                    ),
                    opacity: .random(in: 0.1...0.3)
                )
            }
        }
    }
}
