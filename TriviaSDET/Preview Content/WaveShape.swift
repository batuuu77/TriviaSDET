import SwiftUI

// MARK: - Supporting Structures
struct WaveShape: Shape {
    var frequency: Double
    var amplitude: Double
    var phase: Double
    
    var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let midHeight = height * 0.5
        
        path.move(to: CGPoint(x: 0, y: midHeight))
        
        for x in stride(from: 0, through: width, by: 1) {
            let relativeX = x / width
            let y = sin(relativeX * .pi * frequency + phase) * amplitude + midHeight
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        
        return path
    }
}

struct LightBeam: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX - 50, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX + 50, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX + 100, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX - 100, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct ParticleSystem: View {
    let particleCount = 50
    @State private var particles: [Particle] = []
    
    struct Particle: Identifiable {
        let id = UUID()
        var position: CGPoint
        var scale: CGFloat
        var opacity: Double
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                for particle in particles {
                    let rect = CGRect(
                        x: particle.position.x,
                        y: particle.position.y,
                        width: 2,
                        height: 2
                    )
                    context.opacity = particle.opacity
                    context.fill(
                        Circle().path(in: rect),
                        with: .color(Color.white)
                    )
                }
            }
            .onAppear {
                particles = (0..<particleCount).map { _ in
                    Particle(
                        position: CGPoint(
                            x: .random(in: 0...UIScreen.main.bounds.width),
                            y: .random(in: 0...UIScreen.main.bounds.height)
                        ),
                        scale: .random(in: 0.5...1.5),
                        opacity: .random(in: 0.1...0.3)
                    )
                }
            }
        }
    }
}
