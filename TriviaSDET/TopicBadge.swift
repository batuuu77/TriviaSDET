
import SwiftUI

struct TopicBadge: View {
    let topic: String
    
    private func getTopicColor(_ topic: String) -> Color {
        switch topic {
        case "Java":
            return Color(hex: "f89820")  // Java orange
        case "Selenium":
            return Color(hex: "43B02A")  // Selenium green
        case "SQL":
            return Color(hex: "00758F")  // MySQL blue
        case "Git":
            return Color(hex: "F1502F")  // Git orange-red
        case "API":
            return Color(hex: "61DAFB")  // REST blue
        case "CI/CD":
            return Color(hex: "2560E0")  // DevOps blue
        default:
            return Theme.primary
        }
    }
    
    var body: some View {
        Text(topic)
            .font(.system(.caption, design: .rounded))
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(getTopicColor(topic).opacity(0.3))
                    .overlay(
                        Capsule()
                            .strokeBorder(getTopicColor(topic), lineWidth: 1)
                    )
            )
    }
}
