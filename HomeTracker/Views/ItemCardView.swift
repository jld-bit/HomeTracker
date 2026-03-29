import SwiftUI

struct ItemCardView: View {
    let item: InventoryItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            imageView
            Text(item.name)
                .font(.headline)
                .lineLimit(1)
            Label(item.category, systemImage: "tag.fill")
                .font(.caption)
                .foregroundStyle(.secondary)
            Label(item.room, systemImage: "door.left.hand.open")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(item.estimatedValue.currency)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.green)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white)
        )
        .shadow(color: .black.opacity(0.08), radius: 10, y: 6)
    }

    @ViewBuilder
    private var imageView: some View {
        if let data = item.photoData,
           let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(height: 110)
                .frame(maxWidth: .infinity)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        } else {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.blue.opacity(0.15))
                .frame(height: 110)
                .overlay(Image(systemName: "shippingbox.fill").font(.title).foregroundStyle(.blue))
        }
    }
}
