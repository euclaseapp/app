import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView() {
            Text("hi world")
                .tabItem { Label("General", systemImage: "gear") }
            
            ExtensionListView()
                .tabItem { Label("Extensions", systemImage: "tablecells.fill") }
            
            Text("hmmm")
                .tabItem { Label("About", systemImage: "info.circle.fill") }
        }
        .frame(width: 600, height: 300)
    }
}

struct ExtensionListView: View {
    @EnvironmentObject private var registry: ExtensionRegistry

    var body: some View {
        Table(of: ExtensionCommand.self) {
            TableColumn("Extension", value: \.extensionName)
            TableColumn("Command", value: \.commandID)
            TableColumn("Description", value: \.description)
            TableColumn("Path", value: \.scriptPath)
        } rows: {
            ForEach(registry.commands) { command in
                TableRow(command)
            }
        }
    }
}
