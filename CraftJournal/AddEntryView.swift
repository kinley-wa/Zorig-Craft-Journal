import SwiftUI
import CoreData
import PhotosUI
import UIKit

struct AddEntryView: View {

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var craftType = crafts[0]
    @State private var artisanName = ""
    @State private var notes = ""

    // Part B: Photo
    @State private var image: UIImage?
    @State private var showingCamera = false
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {

        NavigationStack {

            Form {

                TextField("Title", text: $title)

                TextField("Artisan Name", text: $artisanName)

                Picker("Craft", selection: $craftType) {
                    ForEach(crafts, id: \.self) { craft in
                        Text(craft)
                    }
                }

                // Part B: Photo
                Section("Photo") {

                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 250)
                    }

                    Button {
                        showingCamera = true
                    } label: {
                        Label(
                            "Take Photo",
                            systemImage: "camera"
                        )
                    }
                    .disabled(
                        !UIImagePickerController
                            .isSourceTypeAvailable(.camera)
                    )

                    PhotosPicker(
                        selection: $selectedPhoto,
                        matching: .images
                    ) {
                        Label(
                            "Choose from Library",
                            systemImage: "photo"
                        )
                    }
                }

                TextField(
                    "Notes",
                    text: $notes,
                    axis: .vertical
                )
            }

            .navigationTitle("New Entry")

            // Open camera
            .fullScreenCover(
                isPresented: $showingCamera
            ) {
                CameraView(image: $image)
                    .ignoresSafeArea()
            }

            // Choose photo from library
            .onChange(of: selectedPhoto) {
                Task {
                    if let selectedPhoto,
                       let data = try? await selectedPhoto
                            .loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {

                        image = uiImage
                    }
                }
            }

            .toolbar {

                ToolbarItem(
                    placement: .cancellationAction
                ) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(
                    placement: .confirmationAction
                ) {
                    Button("Save") {
                        saveEntry()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }

    private func saveEntry() {

        let entry = CraftEntry(context: viewContext)

        entry.id = UUID()
        entry.title = title
        entry.craftType = craftType
        entry.notes = notes
        entry.date = Date()
        entry.artisanName = artisanName

        // Save photo as Core Data Binary Data
        entry.photo = image?.jpegData(
            compressionQuality: 0.7
        )

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Could not save: \(error)")
        }
    }
}
