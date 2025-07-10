import Foundation
import StoreKit
import Combine

@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published var products: [Product] = []
    @Published var purchasedProductIDs = Set<String>()
    @Published var isSubscribed = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var updateListenerTask: Task<Void, Error>?
    private var cancellables = Set<AnyCancellable>()
    
    // Product IDs
    private let weeklyProductID = "agron_weekly"
    private let yearlyProductID = "agron_yearly"
    
    private init() {
        updateListenerTask = listenForTransactions()
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Product Loading
    
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let productIDs = [weeklyProductID, yearlyProductID]
            products = try await Product.products(for: productIDs)
            isLoading = false
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    // MARK: - Purchase Methods
    
    func purchase(_ product: Product) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // Check whether the transaction is verified
                switch verification {
                case .verified(let transaction):
                    // Deliver content to the user
                    await deliverPurchase(transaction)
                    await transaction.finish()
                case .unverified(_, let error):
                    throw error
                }
            case .userCancelled:
                errorMessage = "Purchase was cancelled"
            case .pending:
                errorMessage = "Purchase is pending"
            @unknown default:
                errorMessage = "Unknown purchase result"
            }
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
        }
        
        isLoading = false
        await updateSubscriptionStatus()
    }
    
    func purchaseWeekly() async {
        guard let product = products.first(where: { $0.id == weeklyProductID }) else {
            errorMessage = "Weekly product not available"
            return
        }
        
        try? await purchase(product)
    }
    
    func purchaseYearly() async {
        guard let product = products.first(where: { $0.id == yearlyProductID }) else {
            errorMessage = "Yearly product not available"
            return
        }
        
        try? await purchase(product)
    }
    
    // MARK: - Restore Purchases
    
    func restorePurchases() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
            isLoading = false
        } catch {
            errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    // MARK: - Subscription Status
    
    func updateSubscriptionStatus() async {
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                purchasedProductIDs.insert(transaction.productID)
                isSubscribed = true
            case .unverified(_, _):
                break
            }
        }
    }
    
    // MARK: - Transaction Listener
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                await self.handleTransactionUpdate(result)
            }
        }
    }
    
    private func handleTransactionUpdate(_ result: VerificationResult<Transaction>) async {
        switch result {
        case .verified(let transaction):
            await deliverPurchase(transaction)
            await transaction.finish()
        case .unverified(_, let error):
            errorMessage = "Transaction verification failed: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Purchase Delivery
    
    private func deliverPurchase(_ transaction: Transaction) async {
        // Update subscription status
        purchasedProductIDs.insert(transaction.productID)
        isSubscribed = true
        
        // Save subscription info to UserDefaults
        UserDefaults.standard.set(true, forKey: "isSubscribed")
        UserDefaults.standard.set(transaction.productID, forKey: "currentSubscriptionID")
        UserDefaults.standard.set(transaction.originalPurchaseDate, forKey: "subscriptionStartDate")
        
        // Notify backend about subscription (if needed)
        await notifyBackendAboutSubscription(transaction)
    }
    
    private func notifyBackendAboutSubscription(_ transaction: Transaction) async {
        // TODO: Implement backend notification
        // This would typically involve calling your API to update the user's subscription status
    }
    
    // MARK: - Helper Methods
    
    func getProduct(for productID: String) -> Product? {
        return products.first { $0.id == productID }
    }
    
    func isProductPurchased(_ productID: String) -> Bool {
        return purchasedProductIDs.contains(productID)
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Subscription Info
    
    func getCurrentSubscriptionInfo() -> (productID: String?, startDate: Date?) {
        let productID = UserDefaults.standard.string(forKey: "currentSubscriptionID")
        let startDate = UserDefaults.standard.object(forKey: "subscriptionStartDate") as? Date
        return (productID, startDate)
    }
    
    func checkSubscriptionStatus() {
        isSubscribed = UserDefaults.standard.bool(forKey: "isSubscribed")
    }
} 