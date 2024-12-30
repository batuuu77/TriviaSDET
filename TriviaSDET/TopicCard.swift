import SwiftUI
struct TopicCard: View {
    var topic: String
    var viewModel: TopicViewModel

    var body: some View {
        VStack {
            Image(systemName: viewModel.iconName(topic: topic))
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.white)
            Text(topic)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.top, 5)
        }
        .padding(.vertical, 20)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 150)
        .background(LinearGradient(gradient: Gradient(colors: [viewModel.color1(topic: topic), viewModel.color2(topic: topic)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}
