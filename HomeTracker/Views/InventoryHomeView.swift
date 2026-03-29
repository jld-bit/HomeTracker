import SwiftUI
import SwiftData

struct InventoryHomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [InventoryItem]

    @StateObject private var viewModel = InventoryViewModel()
    @StateObject private var premiumService = PremiumService.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                filterBar
                statsSection
                contentSection
            }
            .padding(.horizontal)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("HomeTracker")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        viewModel.isGridView.toggle()
                    } label: {
                        Image(systemName: viewModel.isGridView ? "list.bullet" : "square.grid.2x2")
                    }

                    Menu {
                        Button("Export CSV") { exportTapped(.csv) }
                        Button("Export PDF") { exportTapped(.pdf) }
                        Button("Backup JSON") { exportTapped(.backup) }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }

                    Button {
                        addTapped()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search items")
            .sheet(isPresented: $viewModel.showingAddSheet) {
                AddItemView { item in
                    modelContext.insert(item)
                }
            }
            .sheet(isPresented: $viewModel.showingPaywall) {
                PremiumView(premiumService: premiumService)
            }
            .sheet(item: Binding(
                get: { viewModel.exportURL.map(ExportDocument.init(url:)) },
                set: { viewModel.exportURL = $0?.url }
            )) { file in
                ShareSheet(items: [file.url])
            }
        }
    }

    private var filteredItems: [InventoryItem] {
        viewModel.filteredItems(items)
    }

    private var filterBar: some View {
        HStack {
            Picker("Category", selection: $viewModel.selectedCategory) {
                ForEach(viewModel.categories(from: items), id: \.self) { category in
                    Text(category).tag(category)
                }
            }
            .pickerStyle(.menu)

            Picker("Room", selection: $viewModel.selectedRoom) {
                ForEach(viewModel.rooms(from: items), id: \.self) { room in
                    Text(room).tag(room)
                }
            }
            .pickerStyle(.menu)
        }
        .font(.subheadline.weight(.medium))
    }

    private var statsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                StatCardView(
                    title: "Total Items",
                    value: "\(items.count)",
                    icon: "shippingbox.fill",
                    color: .blue
                )

                StatCardView(
                    title: "Inventory Value",
                    value: items.map(\.estimatedValue).reduce(0, +).currency,
                    icon: "dollarsign.circle.fill",
                    color: .green
                )

                ForEach(viewModel.statsByRoom(items).prefix(3), id: \.0) { stat in
                    StatCardView(
                        title: stat.0,
                        value: stat.1.currency,
                        icon: "house.fill",
                        color: .purple
                    )
                }
            }
            .padding(.vertical, 4)
        }
    }

    @ViewBuilder
    private var contentSection: some View {
        if filteredItems.isEmpty {
            ContentUnavailableView(
                "No items yet",
                systemImage: "shippingbox",
                description: Text("Tap + to add your first item.")
            )
        } else if viewModel.isGridView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 12)], spacing: 12) {
                    ForEach(filteredItems) { item in
                        ItemCardView(item: item)
                    }
                }
                .padding(.bottom, 20)
            }
        } else {
            List {
                ForEach(filteredItems) { item in
                    ItemRowView(item: item)
                        .listRowBackground(Color.clear)
                }
                .onDelete(perform: delete)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredItems[index])
        }
    }

    private func addTapped() {
        if viewModel.canAddItem(currentCount: items.count, premiumService: premiumService) {
            viewModel.showingAddSheet = true
        } else {
            viewModel.showingPaywall = true
        }
    }

    private func exportTapped(_ type: ExportType) {
        guard premiumService.isPremium else {
            viewModel.showingPaywall = true
            return
        }
        viewModel.export(items: filteredItems, type: type)
    }
}

private struct ExportDocument: Identifiable {
    let id = UUID()
    let url: URL
}
