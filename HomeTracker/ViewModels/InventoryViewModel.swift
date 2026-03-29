import Foundation
import SwiftData

@MainActor
final class InventoryViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var selectedCategory: String = "All"
    @Published var selectedRoom: String = "All"
    @Published var isGridView: Bool = false
    @Published var showingAddSheet: Bool = false
    @Published var showingPaywall: Bool = false
    @Published var exportURL: URL?

    let freeItemLimit = 25

    func canAddItem(currentCount: Int, premiumService: PremiumService) -> Bool {
        premiumService.isPremium || currentCount < freeItemLimit
    }

    func filteredItems(_ items: [InventoryItem]) -> [InventoryItem] {
        items
            .filter { matchesSearch($0) }
            .filter { matchesCategory($0) }
            .filter { matchesRoom($0) }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func categories(from items: [InventoryItem]) -> [String] {
        let set = Set(items.map(\.category))
        return ["All"] + set.sorted()
    }

    func rooms(from items: [InventoryItem]) -> [String] {
        let set = Set(items.map(\.room))
        return ["All"] + set.sorted()
    }

    func statsByCategory(_ items: [InventoryItem]) -> [(String, Double)] {
        Dictionary(grouping: items, by: \.category)
            .map { key, value in
                (key, value.map(\.estimatedValue).reduce(0, +))
            }
            .sorted { $0.0 < $1.0 }
    }

    func statsByRoom(_ items: [InventoryItem]) -> [(String, Double)] {
        Dictionary(grouping: items, by: \.room)
            .map { key, value in
                (key, value.map(\.estimatedValue).reduce(0, +))
            }
            .sorted { $0.0 < $1.0 }
    }

    func export(items: [InventoryItem], type: ExportType) {
        do {
            exportURL = try ExportService.export(items: items, type: type)
        } catch {
            print("Failed export: \(error)")
        }
    }

    private func matchesSearch(_ item: InventoryItem) -> Bool {
        guard !searchText.isEmpty else { return true }
        let text = searchText.lowercased()
        return item.name.lowercased().contains(text)
            || item.notes.lowercased().contains(text)
            || item.category.lowercased().contains(text)
            || item.room.lowercased().contains(text)
    }

    private func matchesCategory(_ item: InventoryItem) -> Bool {
        selectedCategory == "All" || item.category == selectedCategory
    }

    private func matchesRoom(_ item: InventoryItem) -> Bool {
        selectedRoom == "All" || item.room == selectedRoom
    }
}
