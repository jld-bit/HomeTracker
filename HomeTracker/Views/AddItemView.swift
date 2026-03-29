import PhotosUI
import SwiftUI

struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var category = ""
    @State private var estimatedValue = ""
    @State private var room = ""
    @State private var notes = ""
    @State private var photoData: Data?
    @State private var selectedPhoto: PhotosPickerItem?

    let onSave: (InventoryItem) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Quick Add") {
                    TextField("Item name", text: $name)
                    TextField("Category", text: $category)
                    TextField("Room", text: $room)
                    TextField("Estimated value", text: $estimatedValue)
                        .keyboardType(.decimalPad)
                }

                Section("Photo") {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label("Choose Photo", systemImage: "photo")
                    }

                    if let data = photoData,
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 120)
                }
            }
            .navigationTitle("Add Item")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { save() }
                        .disabled(!canSave)
                }
            }
            .task(id: selectedPhoto) {
                if let selectedPhoto,
                   let data = try? await selectedPhoto.loadTransferable(type: Data.self) {
                    photoData = data
                }
            }
        }
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
            && !category.trimmingCharacters(in: .whitespaces).isEmpty
            && !room.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func save() {
        let value = Double(estimatedValue) ?? 0
        let item = InventoryItem(
            name: name,
            photoData: photoData,
            category: category,
            estimatedValue: value,
            room: room,
            notes: notes
        )

        onSave(item)
        dismiss()
    }
}
