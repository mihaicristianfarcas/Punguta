//
//  ShoppingList.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 20.10.2025.
//

import Foundation
import SwiftData

// MARK: - Shopping List

/// Represents a shopping list containing products via junction model
///
/// **Design Decision**: Lists use ShoppingListItem junction model
/// - Allows the same product to appear in multiple lists
/// - Changes to products are reflected across all lists
/// - Checked state is tracked per list via ShoppingListItem
/// - Supports flexible list management (weekly groceries, party supplies, etc.)
@Model
final class ShoppingList {
    
    // MARK: Properties
    
    /// Unique identifier for the shopping list
    @Attribute(.unique) var id: UUID
    
    /// Display name of the list (e.g., "Weekly Groceries", "Party Supplies")
    var name: String
    
    /// When the list was first created
    var createdAt: Date
    
    /// Last modification timestamp
    var updatedAt: Date
    
    /// Relationship to list items (junction model with products)
    @Relationship(deleteRule: .cascade, inverse: \ShoppingListItem.shoppingList)
    var items: [ShoppingListItem]?
    
    // MARK: Initializer
    
    init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.items = []
    }
    
    // MARK: - Computed Properties
    
    /// Get all products in this list
    var products: [Product] {
        items?.compactMap { $0.product } ?? []
    }
    
    /// Get all checked products in this list
    var checkedProducts: [Product] {
        items?.filter { $0.isChecked }.compactMap { $0.product } ?? []
    }
    
    /// Get all unchecked products in this list
    var uncheckedProducts: [Product] {
        items?.filter { !$0.isChecked }.compactMap { $0.product } ?? []
    }
    
    // MARK: - Mutations
    
    /// Add a product to the list if not already present
    /// - Parameter product: The product to add
    /// - Returns: The created ShoppingListItem or nil if already exists
    @discardableResult
    func addProduct(_ product: Product) -> ShoppingListItem? {
        // Check if product already exists in this list
        guard !(items?.contains(where: { $0.product?.id == product.id }) ?? false) else {
            return nil
        }
        
        let item = ShoppingListItem(product: product, shoppingList: self)
        if items == nil {
            items = []
        }
        items?.append(item)
        updatedAt = Date()
        return item
    }
    
    /// Remove a product from the list
    /// - Parameter product: The product to remove
    /// - Note: This doesn't delete the product itself, just removes it from this list
    func removeProduct(_ product: Product) {
        items?.removeAll { $0.product?.id == product.id }
        updatedAt = Date()
    }
    
    /// Remove a shopping list item
    /// - Parameter item: The item to remove
    func removeItem(_ item: ShoppingListItem) {
        items?.removeAll { $0.id == item.id }
        updatedAt = Date()
    }
    
    /// Toggle the checked state of a product in this list
    /// - Parameter product: The product to toggle
    func toggleProductChecked(_ product: Product) {
        if let item = items?.first(where: { $0.product?.id == product.id }) {
            item.toggleChecked()
            updatedAt = Date()
        }
    }
    
    /// Check if a product is checked in this list
    /// - Parameter product: The product to check
    /// - Returns: True if the product is checked in this list
    func isProductChecked(_ product: Product) -> Bool {
        items?.first(where: { $0.product?.id == product.id })?.isChecked ?? false
    }
    
    /// Clear all checked items from this list
    func clearCheckedItems() {
        items?.forEach { item in
            if item.isChecked {
                item.isChecked = false
            }
        }
        updatedAt = Date()
    }
    
    /// Get the shopping list item for a specific product
    /// - Parameter product: The product to find
    /// - Returns: The ShoppingListItem if found
    func item(for product: Product) -> ShoppingListItem? {
        items?.first(where: { $0.product?.id == product.id })
    }
}
