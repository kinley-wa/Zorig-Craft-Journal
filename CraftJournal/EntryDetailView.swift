import SwiftUI
import CoreData
import UIKit

struct EntryDetailView: View {

    @ObservedObject var entry: CraftEntry

    @State private var showingEdit = false

    var body: some View {

        ScrollView {

            VStack(
                alignment: .leading,
                spacing: 12
            ) {

                // Part B: Show saved photo
                if let data = entry.photo,
                   let uiImage = UIImage(data: data) {

                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 12
                            )
                        )
                }

                Text(entry.title ?? "Untitled")
                    .font(.largeTitle)
                    .bold()

                Text(entry.craftType ?? "")
                    .font(.title3)
                    .foregroundStyle(.secondary)

                Text(
                    "Artisan: \(entry.artisanName ?? "Unknown")"
                )
                .font(.subheadline)

                if let date = entry.date {
                    Text(date, style: .date)
                }

                if let notes = entry.notes,
                   !notes.isEmpty {

                    Text(notes)
                        .font(.body)
                }
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .padding()
        }

        .navigationBarTitleDisplayMode(.inline)

        // M2: Edit button
        .toolbar {
            ToolbarItem(
                placement: .topBarTrailing
            ) {
                Button("Edit") {
                    showingEdit = true
                }
            }
        }

        // M2: Edit sheet
        .sheet(isPresented: $showingEdit) {
            EditEntryView(entry: entry)
        }
    }
}
