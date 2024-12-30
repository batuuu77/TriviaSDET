import Foundation
import StoreKit

class StoreManager: NSObject, ObservableObject, SKPaymentTransactionObserver {
    @Published var availableProducts: [SKProduct] = []
    @Published var purchaseStatus: String = ""
    private let productID = "premiumAccessc1"
    @Published var isSubscriptionActive = false
    
    override init() {
        super.init()
        startObserving()
        fetchProducts()
    }
    
    deinit {
        stopObserving()
    }
    
    private func handlePurchaseSuccess() {
        isSubscriptionActive = true
        UserDefaults.standard.set(true, forKey: "isPremiumUser")
        if let userManager = try? UserManager() {
            userManager.setPremiumStatus(isPremium: true)
        }
    }
    
    // StoreKit 2 transaction handling
    func handleSubscriptionPurchase(_ transaction: StoreKit.Transaction) {
        DispatchQueue.main.async { [weak self] in
            self?.handlePurchaseSuccess()
        }
    }
    
    func startObserving() {
        SKPaymentQueue.default().add(self)
    }
    
    func stopObserving() {
        SKPaymentQueue.default().remove(self)
    }
    
    func fetchProducts() {
        let request = SKProductsRequest(productIdentifiers: [productID])
        request.delegate = self
        request.start()
    }
    
    func purchasePremium() {
        guard let product = availableProducts.first(where: { $0.productIdentifier == productID }) else {
            purchaseStatus = "Product not found."
            return
        }
        
        if SKPaymentQueue.canMakePayments() {
            purchaseStatus = "Processing purchase..."
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        } else {
            purchaseStatus = "In-App Purchases are not allowed"
        }
    }
    
    func restorePurchases() {
        purchaseStatus = "Restoring purchases..."
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                DispatchQueue.main.async { [weak self] in
                    self?.purchaseStatus = "Purchase successful!"
                    self?.handlePurchaseSuccess()
                }
                queue.finishTransaction(transaction)
                
            case .failed:
                DispatchQueue.main.async { [weak self] in
                    if let error = transaction.error as? SKError {
                        self?.purchaseStatus = "Purchase failed: \(error.localizedDescription)"
                    } else {
                        self?.purchaseStatus = "Purchase failed. Please try again."
                    }
                }
                queue.finishTransaction(transaction)
                
            case .restored:
                DispatchQueue.main.async { [weak self] in
                    self?.purchaseStatus = "Purchase restored successfully!"
                    self?.handlePurchaseSuccess()
                }
                queue.finishTransaction(transaction)
                
            case .deferred:
                DispatchQueue.main.async { [weak self] in
                    self?.purchaseStatus = "Purchase awaiting approval"
                }
                
            case .purchasing:
                DispatchQueue.main.async { [weak self] in
                    self?.purchaseStatus = "Processing purchase..."
                }
                
            @unknown default:
                break
            }
        }
    }
}

extension StoreManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async { [weak self] in
            self?.availableProducts = response.products
            if response.products.isEmpty {
                self?.purchaseStatus = "No products found"
            }
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.purchaseStatus = "Failed to load products: \(error.localizedDescription)"
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        DispatchQueue.main.async { [weak self] in
            if queue.transactions.isEmpty {
                self?.purchaseStatus = "No purchases to restore"
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.purchaseStatus = "Restore failed: \(error.localizedDescription)"
        }
    }
}
