import StoreKit
import Foundation
import SwiftUI
struct PurchaseView: View {
    @Binding var showModal: Bool
    @StateObject var storeManager: StoreManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.opacity(0.5).edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text("Upgrade to Premium")
                    .font(.headline)
                    .foregroundColor(.white)

                if let product = storeManager.availableProducts.first {
                    Button(action: {
                        storeManager.purchasePremium()
                    }) {
                        Text("Buy Premium for \(product.localizedPrice)")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                } else {
                    Text("Loading products...")
                        .foregroundColor(.white)
                }

                // Status message
                if !storeManager.purchaseStatus.isEmpty {
                    Text(storeManager.purchaseStatus)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }

                Button(action: {
                    storeManager.restorePurchases()
                }) {
                    Text("Restore Purchases")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: {
                    showModal = false
                }) {
                    Text("Cancel")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            .background(Color.black)
            .cornerRadius(12)
            .padding(.horizontal, 40)
            .onChange(of: storeManager.isSubscriptionActive) { newValue in
                if newValue {
                    // Dismiss the purchase view and navigate to TopicsView
                    showModal = false
                }
            }
        }
    }
}

struct PurchaseView_Previews: PreviewProvider {
    @State static var showModal = true
    static var previews: some View {
        PurchaseView(showModal: $showModal, storeManager: StoreManager())
    }
}
