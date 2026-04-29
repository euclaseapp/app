import SwiftData

@Model
final class ItemRecord {
    var name: String
    var parent: String
    var path: String

    init(name: String, parent: String, path: String) {
        self.name = name
        self.parent = parent
        self.path = path
    }
}
