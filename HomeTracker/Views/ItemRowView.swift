import SwiftUI

struct ItemRowView: View {
    let item: InventoryItem

    var body: some View {
        HStack(spacing: 12) {
            thumbnail

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                HStack {
                    Label(item.category, systemImage: "tag")
                    Label(item.room, systemImage: "house")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Text(item.estimatedValue.currency)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.green)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
        )
    }

    private var thumbnail: some View {
        Group {
            if let data = item.photoData,
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.orange.opacity(0.25))
                    .overlay(Image(systemName: "photo").foregroundStyle(.orange))
            }
        }
        .frame(width: 56, height: 56)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
