import Foundation
import SwiftData

enum Temporary {
    static func insertItem(
        slug: String,
        name: String,
        parent: String,
        path: String,
        in modelContext: ModelContext
    ) {
        let record = CommandRecord(name: name, parent: parent, path: path, slug: slug)
        modelContext.insert(record)

        do {
            try modelContext.save()
        } catch {
            print("Insert failed: \(error)")
        }
    }

    static func readAllItems(in modelContext: ModelContext) -> [CommandRecord] {
        let descriptor = FetchDescriptor<CommandRecord>(sortBy: [SortDescriptor(\.name)])

        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Read failed: \(error)")
            return []
        }
    }

    static func updateItemPath(
        named name: String,
        newPath: String,
        in modelContext: ModelContext
    ) {
        let descriptor = FetchDescriptor<CommandRecord>(
            predicate: #Predicate { $0.name == name }
        )

        do {
            guard let record = try modelContext.fetch(descriptor).first else { return }
            record.path = newPath
            try modelContext.save()
        } catch {
            print("Update failed: \(error)")
        }
    }

    static func deleteItem(
        named name: String,
        in modelContext: ModelContext
    ) {
        let descriptor = FetchDescriptor<CommandRecord>(
            predicate: #Predicate { $0.name == name }
        )

        do {
            guard let record = try modelContext.fetch(descriptor).first else { return }
            modelContext.delete(record)
            try modelContext.save()
        } catch {
            print("Delete failed: \(error)")
        }
    }

    static func bootstrap(in modelContext: ModelContext) {
        let allRecords = readAllItems(in: modelContext)

        for record in allRecords {
            modelContext.delete(record)
        }

        do {
            try modelContext.save()
        } catch {
            print("Reset failed: \(error)")
        }

        insertItem(
            slug: "example-command",
            name: "Example Command",
            parent: "General",
            path: "/usr/local/bin/example-command",
            in: modelContext
        )
    }
}
