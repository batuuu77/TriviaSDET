import SwiftUI

struct TopicsView: View {
    @StateObject var viewModel = TopicViewModel()
    @EnvironmentObject var userManager: UserManager
    @State private var showPremiumUpgrade = false
    @State private var navigationPath = NavigationPath()
    
    // Cache grid layout
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    Text("Interview Topics")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 25)
                    
                    // Free/Premium Status
                    if !userManager.isPremium {
                        HStack {
                            Image(systemName: "hourglass")
                                .foregroundColor(.white)
                            Text("\(userManager.remainingQuestions()) questions remaining")
                                .foregroundColor(.white)
                                .id(userManager.dailyQuestionsAsked)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(20)
                    } else {
                        premiumBadge
                    }
                    
                    // Topics Grid
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.topics, id: \.self) { topic in
                            NavigationLink(value: topic) {
                                TopicCardView(
                                    topic: topic,
                                    action: { handleTopicSelection(topic) },
                                    viewModel: viewModel
                                )
                                .drawingGroup()
                            }
                        }
                        
                        // Coming Soon Card
                        ComingSoonCard()
                            .drawingGroup()
                    }
                    .padding(.horizontal)
                }
            }
            .scrollIndicators(.hidden)
            .background(Color(hex: "050B15").ignoresSafeArea())
            .navigationDestination(for: String.self) { topic in
                QuestionView(topic: topic)
                    .environmentObject(userManager)
            }
        }
        .sheet(isPresented: $showPremiumUpgrade) {
            PremiumPlanView(
                storeManager: StoreManager(),
                showModal: $showPremiumUpgrade
            ) {
                userManager.setPremiumStatus(isPremium: true)
            }
            .environmentObject(userManager)
        }
    }
    
    private func handleTopicSelection(_ topic: String) {
        if userManager.isPremium {
            navigationPath.append(topic)
        } else if userManager.dailyQuestionsAsked >= 5 {
            showPremiumUpgrade = true
        } else {
            navigationPath.append(topic)
        }
    }
    
    private var premiumBadge: some View {
        HStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 24))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "FFD700"), Color(hex: "FDB931")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Premium Member")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(20)
    }
}

struct ComingSoonCard: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "FF6B6B"), Color(hex: "FF8E53")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .opacity(isAnimating ? 0.8 : 0.6)
                
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
            }
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            
            Text("Coding Compiler")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Text("Coming Soon!")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "FF6B6B"), Color(hex: "FF8E53")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .opacity(isAnimating ? 1 : 0.7)
            
            Text("Get ready to code!")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 15)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "1A1F35"))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(hex: "FF6B6B").opacity(0.3),
                                    Color(hex: "FF8E53").opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
            ) {
                isAnimating = true
            }
        }
    }
}

struct TopicsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TopicsView()
                .environmentObject(UserManager())
        }
    }
}
