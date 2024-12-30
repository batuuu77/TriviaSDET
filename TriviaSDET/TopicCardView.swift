import SwiftUI

struct TopicCardView: View {
    let topic: String
    let action: () -> Void
    @ObservedObject var viewModel: TopicViewModel
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                    action()
                }
            }
        }) {
            VStack(alignment: .center, spacing: 12) {
                // Topic Icon
                getTopicIcon(for: topic)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 35, height: 35)
                    .padding(12)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(getTopicColor(for: topic))
                                .shadow(color: getTopicColor(for: topic).opacity(0.5), radius: 5)
                            
                            // Subtle shine effect
                            RoundedRectangle(cornerRadius: 15)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            .white.opacity(0.2),
                                            .clear
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                    )
                    .frame(width: 60, height: 60)
                
                // Topic Title
                Text(topic)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                // Question Count with enhanced styling
                Text("\(viewModel.getQuestionCount(for: topic)) Questions")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .environment(\.colorScheme, .dark)
                    )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .padding(.horizontal, 15)
            .background(
                ZStack {
                    // Base gradient
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    getTopicColor(for: topic).opacity(0.7),
                                    getTopicColor(for: topic).opacity(0.3)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Glassmorphism effect
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .environment(\.colorScheme, .dark)
                        .opacity(0.3)
                    
                    // Border
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.5),
                                    .white.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(color: getTopicColor(for: topic).opacity(0.3), radius: 10, x: 0, y: 5)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getTopicIcon(for topic: String) -> Image {
        switch topic {
        case "Java":
            return Image("javaIcon")
        case "SQL":
            return Image("sqlIcon")
        case "API Testing":
            return Image("apiIcon")
        case "Selenium":
            return Image("seleniumIcon")
        case "Git":
            return Image("gitIcon")
        case "CI/CD":
            return Image("CICDicon")
        case "Random Questions":
            return Image("randomIcon")
        default:
            return Image(systemName: "questionmark.circle.fill")
        }
    }

    private func getTopicColor(for topic: String) -> Color {
        switch topic {
        case "Java":
            return Color(hex: "f89820")
        case "SQL":
            return Color(hex: "00758F")
        case "API Testing":
            return Color(hex: "7B68EE")
        case "Selenium":
            return Color(hex: "43B02A")
        case "Git":
            return Color(hex: "2b3137")
        case "CI/CD":
            return Color(hex: "4B0082")
        case "Random Questions":
            return Color(hex: "6A5ACD")
        default:
            return Color.blue
        }
    }
}
