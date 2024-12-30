import SwiftUI

struct ParticleEffect: View {
    @State private var particles: [Particle] = []
    
    struct Particle: Identifiable {
        let id = UUID()
        var position: CGPoint
        var scale: CGFloat
        var opacity: Double
        var speed: Double
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                for particle in particles {
                    context.opacity = particle.opacity
                    context.scaleBy(x: particle.scale, y: particle.scale)
                    
                    let rect = CGRect(x: particle.position.x,
                                    y: particle.position.y,
                                    width: 2, height: 2)
                    
                    context.fill(Path(ellipseIn: rect), with: .color(.white))
                }
            }
            .onAppear {
                createParticles(count: 50)
            }
            .onChange(of: timeline.date) { _ in
                updateParticles()
            }
        }
    }
    
    private func createParticles(count: Int) {
        for _ in 0..<count {
            particles.append(
                Particle(
                    position: CGPoint(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    ),
                    scale: CGFloat.random(in: 0.5...1.5),
                    opacity: Double.random(in: 0.2...0.7),
                    speed: Double.random(in: 0.5...2)
                )
            )
        }
    }
    
    private func updateParticles() {
        for i in particles.indices {
            var particle = particles[i]
            particle.position.y -= particle.speed
            
            if particle.position.y < -10 {
                particle.position.y = UIScreen.main.bounds.height + 10
                particle.position.x = CGFloat.random(in: 0...UIScreen.main.bounds.width)
            }
            
            particles[i] = particle
        }
    }
}
