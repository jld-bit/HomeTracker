import Foundation
import StoreKit

@MainActor
final class PremiumService: ObservableObject {
    static let shared = PremiumService()

    @Published private(set) var products: [Product] = []
    @Published private(set) var isPremium: Bool = false

    private let productIDs = ["com.hometracker.premium.yearly"]

    private init() {
        Task {
            await loadProducts()
            await refreshSubscriptionStatus()
            await observeTransactions()
        }
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: productIDs)
        } catch {
            print("Unable to load products: \(error)")
        }
    }

    func buyPremium() async throws {
        guard let product = products.first else { return }
        let result = try await product.purchase()

        switch result {
        case let .success(.verified(transaction)):
            await transaction.finish()
            isPremium = true
        case .pending, .userCancelled, .success(.unverified):
            break
        @unknown default:
            break
        }
    }

    func refreshSubscriptionStatus() async {
        for await result in Transaction.currentEntitlements {
            guard case let .verified(transaction) = result else { continue }
            if productIDs.contains(transaction.productID) {
                isPremium = true
                return
            }
        }
        isPremium = false
    }

    private func observeTransactions() async {
        for await update in Transaction.updates {
            guard case let .verified(transaction) = update else { continue }
            if productIDs.contains(transaction.productID) {
                isPremium = true
            }
            await transaction.finish()
        }
    }
}
