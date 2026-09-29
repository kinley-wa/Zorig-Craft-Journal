import SwiftUI
import CoreData

struct ContentView: View {

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest private var entries: FetchedResults<CraftEntry>

    @State private var showingAddEntry = false
    @State private var selectedCraft = "All"
    @State private var searchText = ""
    
    // C3: Sort order
    @State private var selectedSort = "Newest"

    init() {
        _entries = FetchRequest(
            sortDescriptors: [
                NSSortDescriptor(
                    keyPath: \CraftEntry.date,
                    ascending: false
                )
            ],
            animation: .default
        )
    }

    var body: some View {
        NavigationStack {
            VStack {

                // C1: Filter by craft type
                Picker("Craft", selection: $selectedCraft) {
                    Text("All").tag("All")

                    ForEach(crafts, id: \.self) { craft in
                        Text(craft).tag(craft)
                    }
                }
                .pickerStyle(.menu)

                // C3: Sort entries
                Picker("Sort", selection: $selectedSort) {
                    Text("Newest").tag("Newest")
                    Text("Oldest").tag("Oldest")
                    Text("A–Z").tag("A–Z")
                }
                .pickerStyle(.menu)

                // Entry count
                Text("\(filteredEntries.count) entries")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top)

                // Empty journal / no search results
                if filteredEntries.isEmpty {

                    ContentUnavailableView(
                        searchText.isEmpty
                            ? "No Entries Yet"
                            : "No Matching Entries",
                        systemImage: searchText.isEmpty
                            ? "book.closed"
                            : "magnifyingglass",
                        description: Text(
                            searchText.isEmpty
                                ? "Add your first craft entry to get started."
                                : "Try searching for a different title."
                        )
                    )

                } else {

                    List {

                        // C3: Display sorted entries
                        ForEach(sortedEntries) { entry in

                            NavigationLink {
                                EntryDetailView(entry: entry)
                            } label: {
                                EntryRow(entry: entry)
                            }
                        }
                        .onDelete(perform: deleteEntries)
                    }
                }
            }
            .navigationTitle("Craft Journal")

            // C2: Search by title
            .searchable(
                text: $searchText,
                prompt: "Search by title"
            )

            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddEntry = true
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }

            .sheet(isPresented: $showingAddEntry) {
                AddEntryView()
                    .environment(
                        \.managedObjectContext,
                        viewContext
                    )
            }
        }
    }

    // C1 + C2:
    // Filter by craft and search by title
    private var filteredEntries: [CraftEntry] {

        var result = Array(entries)

        // C1: Filter by craft type
        if selectedCraft != "All" {
            result = result.filter {
                $0.craftType == selectedCraft
            }
        }

        // C2: Search by title
        if !searchText.isEmpty {
            result = result.filter {
                ($0.title ?? "")
                    .localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }

    // C3: Sort entries
    private var sortedEntries: [CraftEntry] {

        switch selectedSort {

        case "Oldest":
            return filteredEntries.sorted {
                ($0.date ?? .distantPast) <
                ($1.date ?? .distantPast)
            }

        case "A–Z":
            return filteredEntries.sorted {
                ($0.title ?? "")
                    .localizedCaseInsensitiveCompare(
                        $1.title ?? ""
                    ) == .orderedAscending
            }

        default:
            // Newest first
            return filteredEntries.sorted {
                ($0.date ?? .distantPast) >
                ($1.date ?? .distantPast)
            }
        }
    }

    // Delete entries
    private func deleteEntries(offsets: IndexSet) {

        // Important: use sortedEntries because
        // that is what is displayed on screen
        offsets.map {
            sortedEntries[$0]
        }.forEach(viewContext.delete)

        do {
            try viewContext.save()
        } catch {
            print("Could not delete: \(error)")
        }
    }
}

struct EntryRow: View {

    @ObservedObject var entry: CraftEntry

    var body: some View {

        HStack {

            // Photo thumbnail
            if let data = entry.photo,
               let uiImage = UIImage(data: data) {

                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 8)
                    )

            } else {

                Image(systemName: "photo")
                    .frame(width: 60, height: 60)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading) {

                Text(entry.title ?? "Untitled")
                    .font(.headline)

                Text(entry.craftType ?? "")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(entry.artisanName ?? "")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
            PersistenceController.preview.container.viewContext
        )
}
