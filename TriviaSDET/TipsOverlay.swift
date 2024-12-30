import SwiftUI

struct TipsOverlay: View {
    @Binding var isPresented: Bool
    
    private let tips = [
        "Focus on clear communication",
        "Provide specific examples",
        "Structure your response",
        "Address edge cases",
        "Demonstrate problem-solving"
    ]
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Interview Tips")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 15) {
                    ForEach(tips, id: \.self) { tip in
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Theme.primary)
                            
                            Text(tip)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.05))
                )
                
                Button("Got it!") {
                    withAnimation {
                        isPresented = false
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Theme.primary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
        .transition(.opacity)
    }
}
