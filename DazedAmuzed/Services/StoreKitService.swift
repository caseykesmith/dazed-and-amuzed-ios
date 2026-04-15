//
//  StoreKitService.swift
//  DazedAmuzed
//
//  Created by PJ on 4/14/26.
//


import StoreKit
import SwiftUI
import Combine

@MainActor
class StoreKitService: ObservableObject {
    static let shared = StoreKitService()
    
    // Product IDs - must match App Store Connect
    static let premiumUnlock = "com.dazedamuzed.premium"
    static let musicTrivia = "com.dazedamuzed.pack.musictrivia"
    static let reunion = "com.dazedamuzed.pack.reunion"
    static let bachelorette = "com.dazedamuzed.pack.bachelorette"
    static let couplesNight = "com.dazedamuzed.pack.couplesnight"
    static let afterDark = "com.dazedamuzed.pack.afterdark"
    static let firstDate = "com.dazedamuzed.pack.firstdate"
    
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isLoading = false
    
    private var updateListenerTask: Task<Void, Error>? = nil
    
    private let productIDs: Set<String> = [
        premiumUnlock,
        musicTrivia,
        reunion,
        bachelorette,
        couplesNight,
        afterDark,
        firstDate
    ]
    
    init() {
        updateListenerTask = listenForTransactions()
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Load Products
    
    func loadProducts() async {
        isLoading = true
        do {
            products = try await Product.products(for: productIDs)
            products.sort { $0.price < $1.price }
        } catch {
            print("Failed to load products: \(error)")
        }
        isLoading = false
    }
    
    // MARK: - Purchase
    
    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updatePurchasedProducts()
            await transaction.finish()
            return true
            
        case .userCancelled:
            return false
            
        case .pending:
            return false
            
        @unknown default:
            return false
        }
    }
    
    // MARK: - Check Ownership
    
    func isPurchased(_ productID: String) -> Bool {
        purchasedProductIDs.contains(productID)
    }
    
    var hasPremium: Bool {
        isPurchased(StoreKitService.premiumUnlock)
    }
    
    func hasAccess(to packID: String) -> Bool {
        hasPremium || isPurchased(packID)
    }
    
    // MARK: - Restore Purchases
    
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {
            print("Failed to restore purchases: \(error)")
        }
    }
    
    // MARK: - Private Helpers
    
    private func updatePurchasedProducts() async {
        var purchased: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchased.insert(transaction.productID)
            }
        }
        
        purchasedProductIDs = purchased
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await self.updatePurchasedProducts()
                    await transaction.finish()
                }
            }
        }
    }
}

enum StoreError: Error {
    case failedVerification
}
