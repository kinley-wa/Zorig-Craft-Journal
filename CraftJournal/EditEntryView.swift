import SwiftUI
import CoreData
import PhotosUI
import UIKit

struct EditEntryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var entry: CraftEntry

    @State private var title: String
    @State private var craftType: String
    @State private var artisanName: String
    @State private var notes: String

    init(entry: CraftEntry) {
        self.entry = entry

        _title = State(initialValue: entry.title ?? "")
        _craftType = State(initialValue: entry.craftType ?? "")
        _artisanName = State(initialValue: entry.artisanName ?? "")
        _notes = State(initialValue: entry.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Entry Details") {
                    TextField("Title", text: $title)

                    Picker("Craft", selection: $craftType) {
                        ForEach(crafts, id: \.self) { craft in
                            Text(craft)
                        }
                    }

                    TextField("Artisan Name", text: $artisanName)

                    TextField("Notes", text: $notes, axis: .vertical)
                }
            }
            .navigationTitle("Edit Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                }
            }
        }
    }

    private func saveChanges() {
        entry.title = title
        entry.craftType = craftType
        entry.artisanName = artisanName
        entry.notes = notes

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error saving changes: \(error.localizedDescription)")
        }
    }
}//
//  EditEntryView.swift
//  CraftJournal
//
//  Created by iMac24 on 9/29/26.
//

