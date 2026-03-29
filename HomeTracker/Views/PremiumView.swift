import SwiftUI
import StoreKit

struct PremiumView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var premiumService: PremiumService

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.yellow)

                Text("HomeTracker Premium")
                    .font(.title2.bold())

                VStack(alignment: .leading, spacing: 12) {
                    premiumBullet("Unlimited items")
                    premiumBullet("CSV + PDF exports")
                    premiumBullet("Cloud backup")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.blue.opacity(0.08))
                )

                if let product = premiumService.products.first {
                    Button {
                        Task {
                            try? await premiumService.buyPremium()
                            if premiumService.isPremium {
                                dismiss()
                            }
                        }
                    } label: {
                        Text("Upgrade for \(product.displayPrice)/year")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                } else {
                    ProgressView("Loading price...")
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Go Premium")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func premiumBullet(_ text: String) -> some View {
        Label(text, systemImage: "checkmark.seal.fill")
            .foregroundStyle(.primary)
    }
}
