import SwiftUI
import SwiftData

struct SettingsView: View {
    var body: some View {
        TabView() {
            Text("hi world")
                .tabItem { Label("General", systemImage: "gear") }
            
            ExtensionListView()
                .modelContainer(for: CommandRecord.self)
                .tabItem { Label("Extensions", systemImage: "tablecells.fill") }
            
            Text("hmmm")
                .tabItem { Label("About", systemImage: "info.circle.fill") }
        }
        .frame(width: 600, height: 300)
    }
}

struct ExtensionListView: View {
    @Query(sort: [SortDescriptor(\CommandRecord.name)])
    private var rows: [CommandRecord]

    var body: some View {
        Table(of: CommandRecord.self) {
            TableColumn("Slug", value: \.slug)
            TableColumn("Name", value: \.name)
            TableColumn("Parent", value: \.parent)
            TableColumn("Path", value: \.path)
        } rows: {
            ForEach(rows, id: \.persistentModelID) { row in
                TableRow(row)
            }
        }
    }
}
