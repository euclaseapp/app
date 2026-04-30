import SwiftData

@Model
final class ItemRecord {
    var slug: String
    var name: String
    var parent: String
    var path: String

    init(name: String, parent: String, path: String, slug: String) {
        self.slug = slug
        self.name = name
        self.parent = parent
        self.path = path
    }
}
