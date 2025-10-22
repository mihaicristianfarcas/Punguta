//
//  ShoppingList.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 20.10.2025.
//

import Foundation

// MARK: - Shopping List

/// Represents a shopping list containing references to products
///
/// **Design Decision**: Lists store product IDs, not the products themselves
/// - Allows the same product to appear in multiple lists
/// - Changes to products are reflected across all lists
/// - Supports flexible list management (weekly groceries, party supplies, etc.)
struct ShoppingList: Identifiable, Codable, Hashable {
    
    // MARK: Properties
    
    /// Unique identifier for the shopping list
    let id: UUID
    
    /// Display name of the list (e.g., "Weekly Groceries", "Party Supplies")
    var name: String
    
    /// Array of product IDs belonging to this list
    /// References products in the global products array
    var productIds: [UUID]
    
    /// When the list was first created
    let createdAt: Date
    
    /// Last modification timestamp
    var updatedAt: Date
    
    // MARK: Initializer
    
    init(
        id: UUID = UUID(),
        name: String,
        productIds: [UUID] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.productIds = productIds
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: Mutations
    
    /// Add a product to the list if not already present
    /// - Parameter productId: The ID of the product to add
    mutating func addProduct(_ productId: UUID) {
        guard !productIds.contains(productId) else { return }
        productIds.append(productId)
        updatedAt = Date()
    }
    
    /// Remove a product from the list
    /// - Parameter productId: The ID of the product to remove
    /// - Note: This doesn't delete the product itself, just removes it from this list
    mutating func removeProduct(_ productId: UUID) {
        productIds.removeAll { $0 == productId }
        updatedAt = Date()
    }
}
