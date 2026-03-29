import Foundation
import SwiftData

@Model
final class InventoryItem {
    var id: UUID
    var name: String
    var photoData: Data?
    var category: String
    var estimatedValue: Double
    var room: String
    var notes: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        photoData: Data? = nil,
        category: String,
        estimatedValue: Double,
        room: String,
        notes: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.photoData = photoData
        self.category = category
        self.estimatedValue = estimatedValue
        self.room = room
        self.notes = notes
        self.createdAt = createdAt
    }
}
