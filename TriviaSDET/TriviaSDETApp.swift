import SwiftUI
import StoreKit

@main
struct TriviaSDETApp: App {
    @StateObject private var userManager = UserManager()
    @StateObject private var storeManager = StoreManager()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
                    .environmentObject(userManager)
                    .environmentObject(storeManager)
                    .task {
                        // Check for any existing premium status
                        let isPremium = UserDefaults.standard.bool(forKey: "isPremiumUser")
                        userManager.setPremiumStatus(isPremium: isPremium)
                        storeManager.isSubscriptionActive = isPremium
                        
                        // Setup subscription handling
                        setupSubscriptionHandling()
                    }
                    .onReceive(storeManager.$isSubscriptionActive) { isActive in
                        // Update UserManager when subscription status changes
                        userManager.setPremiumStatus(isPremium: isActive)
                    }
            }
        }
    }
}

extension TriviaSDETApp {
    private func setupSubscriptionHandling() {
        // Listen for StoreKit messages about subscription status changes
        Task {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    // Handle the subscription transaction
                    await MainActor.run {
                        storeManager.handleSubscriptionPurchase(transaction)
                    }
                    
                    // End the transaction
                    await transaction.finish()
                }
            }
        }
    }
}
