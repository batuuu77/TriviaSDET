import SwiftUI
import StoreKit

struct PremiumPlanView: View {
    @ObservedObject var storeManager: StoreManager
    @EnvironmentObject var userManager: UserManager
    @Binding var showModal: Bool
    var onPremiumPurchased: (() -> Void)?
    @State private var animateGradient = false
    @State private var showPremiumFeatures = false
    private let textToSpeechHelper = TextToSpeechHelper.shared
    
    var body: some View {
        ZStack {
            // Premium animated background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "1a1a1a"),
                    Color(hex: "2d1f3d"),
                    Color(hex: "1f1f1f")
                ]),
                startPoint: animateGradient ? .topLeading : .bottomLeading,
                endPoint: animateGradient ? .bottomTrailing : .topTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: animateGradient)
            .onAppear { animateGradient = true }
            
            // Content
            ScrollView {
                VStack(spacing: 25) {
                    // Premium Header
                    VStack(spacing: 15) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "FFD700"), Color(hex: "FDB931")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color(hex: "FFD700").opacity(0.5), radius: 10)
                        
                        Text("Unlock Premium")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, Color(hex: "E2E2E2")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .padding(.top, 30)
                    
                    // What's included button
                    Button(action: {
                        showPremiumFeatures = true
                    }) {
                        HStack {
                            Text("What's included?")
                                .font(.system(size: 16, weight: .medium))
                            Image(systemName: "chevron.right")
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    // Premium Features
                    VStack(spacing: 20) {
                        featureRow(icon: "infinity", title: "Unlimited Questions", description: "Practice as much as you want")
                        featureRow(icon: "star.fill", title: "Premium Content", description: "Access all interview questions")
                        featureRow(icon: "chart.line.uptrend.xyaxis", title: "Track Progress", description: "Monitor your improvement")
                        featureRow(icon: "clock.fill", title: "No Time Limits", description: "Learn at your own pace")
                    }
                    .padding(.horizontal)
                    
                    // Pricing Section
                    if storeManager.availableProducts.isEmpty {
                        loadingView
                    } else {
                        pricingSection
                    }
                    
                    // Purchase Status
                    if !storeManager.purchaseStatus.isEmpty {
                        Text(storeManager.purchaseStatus)
                            .foregroundColor(storeManager.purchaseStatus.contains("Failed") ? .red : .green)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
                .padding(.bottom, 30)
            }
            
            // Close Button
            VStack {
                HStack {
                    Spacer()
                    Button(action: { showModal = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white.opacity(0.6))
                            .padding()
                    }
                }
                Spacer()
            }
        }
        .sheet(isPresented: $showPremiumFeatures) {
            PremiumFeaturesView(
                storeManager: storeManager,
                userManager: userManager,
                showModal: $showModal,
                onPremiumPurchased: onPremiumPurchased
            )
        }
        .onAppear {
            storeManager.fetchProducts()
        }
        .onDisappear {
            storeManager.purchaseStatus = ""
        }
        .onChange(of: storeManager.isSubscriptionActive) { isActive in
            if isActive {
                onPremiumPurchased?()
                showModal = false
            }
        }
    }
    
    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(Color(hex: "FFD700"))
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var loadingView: some View {
        Text("Loading...")
            .foregroundColor(.white)
            .padding()
            .onAppear {
                storeManager.fetchProducts()
            }
    }
    
    private func handleContinueFree() {
        textToSpeechHelper.stopSpeaking()
        showModal = false
    }
    
    private var pricingSection: some View {
        VStack(spacing: 20) {
            if let product = storeManager.availableProducts.first {
                VStack(spacing: 8) {
                    Text("Monthly Premium")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(product.localizedPrice ?? "$9.99")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Color(hex: "FFD700"))
                    
                    Text("per month")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
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
                .padding(.horizontal)
            }
        }
        .padding(.horizontal)
    }
}
