import SwiftUI

struct LoadingStep: View {
    let phase: LoadingPhase
    let isCompleted: Bool
    let isActive: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle.fill")
                .foregroundColor(isCompleted ? Theme.primary :
                               isActive ? Theme.secondary : Color.white.opacity(0.3))
            
            Text(phase.title)
                .font(.subheadline)
                .foregroundColor(isActive ? .white : .white.opacity(0.7))
            
            Spacer()
        }
        .padding(.horizontal)
    }
}
