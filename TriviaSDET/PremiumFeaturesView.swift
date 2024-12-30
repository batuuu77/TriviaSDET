import SwiftUI
import StoreKit

struct PremiumFeaturesView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var storeManager: StoreManager
    @ObservedObject var userManager: UserManager
    @Binding var showModal: Bool
    var onPremiumPurchased: (() -> Void)?
    @State private var animateGradient = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    headerSection
                    
                    featuresGrid
                    
                    detailedFeaturesList
                    
                    if let product = storeManager.availableProducts.first {
                        VStack(spacing: 8) {
                            Text("Monthly Premium")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text(product.localizedPrice ?? "$7.99")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(Color(hex: "FFD700"))
                            
                            Text("per month")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                            
                            VStack(spacing: 12) {
                                // Upgrade Now button
                                Button(action: {
                                    storeManager.purchasePremium()
                                }) {
                                    HStack {
                                        Text("Upgrade Now")
                                            .font(.system(size: 18, weight: .bold))
                                        Image(systemName: "arrow.right")
                                    }
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            colors: [Color(hex: "FFD700"), Color(hex: "FDB931")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(12)
                                    .shadow(color: Color(hex: "FFD700").opacity(0.3), radius: 10)
                                }
                                
                                // Restore Purchase button
                                Button(action: {
                                    storeManager.restorePurchases()
                                }) {
                                    HStack {
                                        Text("Restore Purchase")
                                            .font(.system(size: 16, weight: .medium))
                                        Image(systemName: "arrow.clockwise")
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(12)
                                }
                            }
                            .padding(.top, 20)
                            .padding(.horizontal)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.05))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "FFD700").opacity(0.5),
                                            Color(hex: "FFD700").opacity(0.2)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .padding()
                    }
                }
                .padding()
            }
            .background(backgroundLayer)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
            }
            .onChange(of: storeManager.isSubscriptionActive) { isActive in
                if isActive {
                    onPremiumPurchased?()
                    showModal = false
                    dismiss()
                }
            }
        }
    }
    
    private var backgroundLayer: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "050B15"),
                Color(hex: "0A1428"),
                Color(hex: "0F1635")
            ]),
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: animateGradient)
        .onAppear { animateGradient = true }
    }
    
    private var headerSection: some View {
        VStack(spacing: 15) {
            Image(systemName: "crown.fill")
                .font(.system(size: 40))
                .foregroundColor(Color(hex: "FFD700"))
            
            Text("Premium Features")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Everything you get with Premium")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.vertical)
    }
    
    private var featuresGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 20) {
            FeatureCard(icon: "infinity", title: "Unlimited Questions", description: "No daily limits")
            FeatureCard(icon: "chart.bar.fill", title: "Analytics", description: "Track your progress")
            FeatureCard(icon: "doc.text.fill", title: "Sample Answers", description: "Expert examples")
            FeatureCard(icon: "star.fill", title: "Premium Topics", description: "Extra content")
        }
    }
    
    private var detailedFeaturesList: some View {
        VStack(alignment: .leading, spacing: 25) {
            Text("Detailed Features")
                .font(.title3.bold())
                .foregroundColor(.white)
                .padding(.top)
            
            ForEach(PremiumFeature.allFeatures) { feature in
                DetailedFeatureRow(feature: feature)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(Color(hex: "FFD700"))
            
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            Text(description)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct DetailedFeatureRow: View {
    let feature: PremiumFeature
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: feature.icon)
                .font(.system(size: 24))
                .foregroundColor(Color(hex: "FFD700"))
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(feature.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(feature.description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(.vertical, 5)
    }
}

struct PremiumFeature: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    
    static let allFeatures = [
        PremiumFeature(
            icon: "infinity",
            title: "Unlimited Questions",
            description: "Practice as much as you want with no daily limits"
        ),
        PremiumFeature(
            icon: "chart.bar.fill",
            title: "Detailed Analytics",
            description: "Track your progress and identify areas for improvement"
        ),
        PremiumFeature(
            icon: "doc.text.fill",
            title: "Sample Answers",
            description: "Access expert-written sample answers for every question"
        ),
        PremiumFeature(
            icon: "star.fill",
            title: "Premium Topics",
            description: "Access additional specialized interview topics"
        ),
        PremiumFeature(
            icon: "person.fill",
            title: "Personalized Feedback",
            description: "Get detailed feedback on your responses"
        ),
        PremiumFeature(
            icon: "arrow.clockwise",
            title: "Regular Updates",
            description: "Access to new questions and features as they're added"
        )
    ]
}
struct PremiumFeaturesView_Previews: PreviewProvider {
    static var previews: some View {
        PremiumFeaturesView(
            storeManager: StoreManager(),
            userManager: UserManager(),
            showModal: .constant(false),
            onPremiumPurchased: nil
        )
    }
}
