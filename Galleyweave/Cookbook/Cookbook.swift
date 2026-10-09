import Foundation

/// One recipe kept for seating. The cookbook is this list, not a shop.
struct CookbookItem: Identifiable, Codable, Equatable, Sendable {
    var id: UUID
    var recipe: Recipe

    init(recipe: Recipe) {
        self.id = recipe.id
        self.recipe = recipe
    }
}

/// Saved meals the berths can Seat. Search writes here. Views read it from the store.
struct Cookbook: Equatable, Sendable, Codable {
    var items: [CookbookItem]

    init(items: [CookbookItem] = []) {
        self.items = items
    }

    func recipe(id: UUID) -> Recipe? {
        items.first { $0.id == id }?.recipe
    }

    var isEmpty: Bool { items.isEmpty }
}
