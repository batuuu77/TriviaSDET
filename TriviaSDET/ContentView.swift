import SwiftUI

struct ContentView: View {
    @StateObject private var storeManager = StoreManager()
    @StateObject private var userManager = UserManager()
    @State private var showPremiumPlanView = false
    @State private var navigateToTopics = false
    @State private var animateGradient = false
    @State private var showSwipeInstruction = false
    @State private var isTimerActive = false
    @State private var swipeOffset: CGFloat = 0
    
    // Timer animation states
    @State private var rotationDegree: Double = 0
    @State private var timerScale: CGFloat = 1
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundLayer
                
                if navigateToTopics {
                    TopicsView()
                        .environmentObject(userManager)
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 30) {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "4CA1AF"),
                                            Color(hex: "C779D0")
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 200, height: 100)
                                .overlay(
                                    Image("TriviaSDETlogo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                        .scaleEffect(1.5)
                                        .clipShape(Circle())
                                        .foregroundColor(.white)
                                )
                                .shadow(color: Color(hex: "4CA1AF").opacity(0.5), radius: 20)
                            
                            if !userManager.canAskMoreQuestions() && !userManager.isPremium {
                                limitReachedSection
                            } else {
                                regularIntroSection
                            }
                            
                            Spacer()
                            
                            descriptionCard
                            
                            Spacer()
                            
                            VStack(spacing: 16) {
                                if userManager.isPremium {
                                    // Premium user - show swipeable button
                                    HStack {
                                        Text("Swipe right to start")
                                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 18, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        LinearGradient(
                                            colors: [Color(hex: "4CA1AF"), Color(hex: "C779D0")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(.white.opacity(0.2), lineWidth: 1)
                                    )
                                    .shadow(color: Color(hex: "4CA1AF").opacity(0.3), radius: 15)
                                    .offset(x: swipeOffset)
                                    .gesture(
                                        DragGesture()
                                            .onChanged { gesture in
                                                if gesture.translation.width > 0 {
                                                    swipeOffset = gesture.translation.width
                                                }
                                            }
                                            .onEnded { gesture in
                                                if gesture.translation.width > 100 {
                                                    navigateToTopics = true
                                                }
                                                withAnimation {
                                                    swipeOffset = 0
                                                }
                                            }
                                    )
                                } else {
                                    // Non-premium user buttons
                                    Button(action: { showPremiumPlanView = true }) {
                                        premiumButton
                                    }
                                    
                                    Button(action: {
                                        if userManager.canAskMoreQuestions() {
                                            userManager.markIntroAsSeen()
                                        }
                                        navigateToTopics = true
                                    }) {
                                        Text(userManager.canAskMoreQuestions() ? "Continue with Free Version" : "View Topics")
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .foregroundColor(.white.opacity(0.9))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 16)
                                            .background(.ultraThinMaterial)
                                            .environment(\.colorScheme, .dark)
                                            .clipShape(RoundedRectangle(cornerRadius: 15))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 15)
                                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                                            )
                                    }
                                }
                            }
                            .padding(.bottom, 50)
                        }
                        .padding()
                    }
                }
            }
            .sheet(isPresented: $showPremiumPlanView) {
                PremiumPlanView(
                    storeManager: storeManager,
                    showModal: $showPremiumPlanView
                ) {
                    navigateToTopics = true
                }
                .environmentObject(userManager)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            if !userManager.canAskMoreQuestions() {
                startTimerAnimation()
            }
        }
    }
    
    private var limitReachedSection: some View {
        VStack(spacing: 25) {
            Text("Daily Limit Reached")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.top)
            
            ZStack {
                // Outer ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(hex: "4CA1AF").opacity(0.3),
                                Color(hex: "C779D0").opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 8
                    )
                    .frame(width: 160, height: 160)
                
                // Animated ring
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(hex: "4CA1AF"),
                                Color(hex: "C779D0")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(
                            lineWidth: 8,
                            lineCap: .round
                        )
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(rotationDegree))
                
                // Time display
                VStack(spacing: 5) {
                    Text(userManager.getTimeUntilReset())
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("remaining")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                .scaleEffect(timerScale)
            }
            
            VStack(spacing: 15) {
                Text("You've used all 5 free questions for today")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    showPremiumPlanView = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "crown.fill")
                            .foregroundColor(Color(hex: "FFD700"))
                        Text("Upgrade to Premium for unlimited access!")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color(hex: "FFD700").opacity(0.1))
                    .cornerRadius(12)
                }
            }
            .padding(.top, 10)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.2),
                                    .clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 10)
    }
    
    private var regularIntroSection: some View {
        VStack(spacing: 15) {
            Text("SDET Interview Prep")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, Color(hex: "E2E2E2")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color(hex: "4CA1AF").opacity(0.5), radius: 10)
            
            Text("Master Your Technical Interview")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
            
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "4CA1AF"))
                    Text("300+ Interview Questions")
                        .foregroundColor(.white.opacity(0.9))
                }
                
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "4CA1AF"))
                    Text("Real-world Scenarios")
                        .foregroundColor(.white.opacity(0.9))
                }
                
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "4CA1AF"))
                    Text("Expert-curated Content")
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .font(.system(size: 16, weight: .medium, design: .rounded))
        }
    }
    
    private func startTimerAnimation() {
        withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
            rotationDegree = 360
        }
        
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            timerScale = 1.05
        }
    }
    
    private var backgroundLayer: some View {
        ZStack {
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
            
            GeometryReader { geometry in
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "4CA1AF").opacity(0.07),
                                    .clear
                                ]),
                                center: .topLeading,
                                startRadius: 100,
                                endRadius: geometry.size.width
                            )
                        )
                        .offset(x: -geometry.size.width/4, y: -geometry.size.height/4)
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "C779D0").opacity(0.05),
                                    .clear
                                ]),
                                center: .bottomTrailing,
                                startRadius: 100,
                                endRadius: geometry.size.width
                            )
                        )
                        .offset(x: geometry.size.width/4, y: geometry.size.height/4)
                }
            }
            .drawingGroup()
        }
    }
    
    private var descriptionCard: some View {
        Text("This app is designed for SDETs who are actively job hunting or refreshing their technical knowledge.")
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .multilineTextAlignment(.center)
            .foregroundColor(.white.opacity(0.9))
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
            )
            .overlay(
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
            )
    }
    
    private var premiumButton: some View {
        HStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.title2)
            Text("Get Premium Access")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
        }
        .foregroundColor(.black)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                colors: [
                    Color(hex: "FFD700"),
                    Color(hex: "FDB931")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(color: Color(hex: "FFD700").opacity(0.3), radius: 15)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
