import SwiftUI
import SwiftData

@main
struct HomeTrackerApp: App {
    private let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(
                for: InventoryItem.self,
                configurations: ModelConfiguration("HomeTracker")
            )
        } catch {
            fatalError("Failed to initialize data container: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(nil)
        }
        .modelContainer(modelContainer)
    }
}
