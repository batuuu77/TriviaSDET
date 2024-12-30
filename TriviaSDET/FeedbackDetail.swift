import SwiftUI

struct FeedbackDetail: View {
    let feedback: FeedbackDetails
    @Binding var selectedTab: Int
    
    // Define colors as static properties
    private static let primaryColor = Color("4CA1AF") // You'll need to add these colors to your asset catalog
    private static let secondaryColor = Color("C779D0")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            switch selectedTab {
            case 0:
                overviewSection
            case 1:
                technicalSection
            case 2:
                communicationSection
            case 3:
                improvementSection
            default:
                overviewSection
            }
        }
        .padding()
        .animation(.easeInOut, value: selectedTab)
    }
    
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            feedbackRow(
                icon: "checkmark.circle.fill",
                color: Self.primaryColor,
                title: "Strengths",
                content: feedback.technical
            )
            
            feedbackRow(
                icon: "arrow.up.circle.fill",
                color: Self.secondaryColor,
                title: "Areas for Improvement",
                content: feedback.communication
            )
        }
    }
    
    private var technicalSection: some View {
        feedbackRow(
            icon: "cpu",
            color: Self.primaryColor,
            title: "Technical Analysis",
            content: feedback.technical
        )
    }
    
    private var communicationSection: some View {
        feedbackRow(
            icon: "message.fill",
            color: Self.secondaryColor,
            title: "Communication",
            content: feedback.communication
        )
    }
    
    private var improvementSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Suggested Improvements")
                .font(.headline)
                .foregroundColor(.white)
            
            ForEach(feedback.improvements, id: \.self) { improvement in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(Self.secondaryColor)
                    
                    Text(improvement)
                        .foregroundColor(.white.opacity(0.9))
                }
            }
        }
    }
    
    private func feedbackRow(icon: String, color: Color, title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            Text(content)
                .foregroundColor(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// Preview provider
struct FeedbackDetail_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackDetail(
            feedback: FeedbackDetails(
                technical: "Strong technical knowledge demonstrated",
                communication: "Clear and concise communication",
                completeness: "Comprehensive answer provided",
                improvements: ["Work on specific examples", "Add more context"]
            ),
            selectedTab: .constant(0)
        )
        .preferredColorScheme(.dark)
        .background(Color.black)
    }
}
