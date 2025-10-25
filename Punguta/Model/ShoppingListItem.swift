//
//  ShoppingListItem.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 25.10.2025.
//

import Foundation
import SwiftData

// MARK: - Shopping List Item

/// Junction model representing a product in a specific shopping list
///
/// **Design Decision**: Junction model for many-to-many relationship
/// - Allows same product to be in multiple lists
/// - Tracks checked state per list (not globally)
/// - Enables list-specific product management
/// - Provides flexibility for future per-list customization
@Model
final class ShoppingListItem {
    
    // MARK: Properties
    
    /// Unique identifier for this list-product relationship
    @Attribute(.unique) var id: UUID
    
    /// Whether this product is checked off in this specific list
    var isChecked: Bool
    
    /// When this item was added to the list
    var addedAt: Date
    
    /// The shopping list this item belongs to
    var shoppingList: ShoppingList?
    
    /// The product referenced by this item
    var product: Product?
    
    // MARK: Initializer
    
    init(
        id: UUID = UUID(),
        product: Product,
        shoppingList: ShoppingList,
        isChecked: Bool = false,
        addedAt: Date = Date()
    ) {
        self.id = id
        self.product = product
        self.shoppingList = shoppingList
        self.isChecked = isChecked
        self.addedAt = addedAt
    }
    
    // MARK: Mutations
    
    /// Toggle the checked state of this item
    func toggleChecked() {
        isChecked.toggle()
    }
}
