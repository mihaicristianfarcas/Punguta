//
//  ListViewModel.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 21.10.2025.
//

import Foundation
import SwiftUI
import SwiftData
import Combine

// MARK: - List View Model

/// Manages shopping lists using SwiftData
///
/// **Responsibilities**:
/// - CRUD operations for shopping lists via ModelContext
/// - List-product relationship management
///
/// **Design Pattern**: MVVM with SwiftData
/// - Lightweight business logic coordinator
/// - SwiftData handles persistence and relationships automatically
/// - Uses ModelContext for database operations
@MainActor
class ListViewModel: ObservableObject {
    
    // MARK: Private Properties
    
    /// SwiftData model context for database operations
    private let modelContext: ModelContext
    
    // MARK: Initializer
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Shopping List Operations
    
    /// Create a new shopping list
    /// - Parameter name: Display name for the list
    /// - Returns: The newly created shopping list
    @discardableResult
    func createList(name: String) -> ShoppingList {
        let list = ShoppingList(name: name)
        modelContext.insert(list)
        try? modelContext.save()
        return list
    }
    
    /// Update a shopping list (SwiftData tracks changes automatically)
    /// - Parameter list: The list to update
    func updateList(_ list: ShoppingList) {
        list.updatedAt = Date()
        try? modelContext.save()
    }
    
    /// Delete a shopping list
    /// - Parameter list: The list to delete
    /// - Note: Cascade delete will remove associated ShoppingListItems
    func deleteList(_ list: ShoppingList) {
        modelContext.delete(list)
        try? modelContext.save()
    }
    
    /// Delete shopping lists
    /// - Parameter lists: Array of lists to delete
    func deleteLists(_ lists: [ShoppingList]) {
        for list in lists {
            modelContext.delete(list)
        }
        try? modelContext.save()
    }
    
    // MARK: - List-Product Relationship
    
    /// Add a product to a shopping list
    /// - Parameters:
    ///   - product: The product to add
    ///   - list: The shopping list
    func addProduct(_ product: Product, to list: ShoppingList) {
        list.addProduct(product)
        try? modelContext.save()
    }
    
    /// Remove a product from a shopping list
    /// - Parameters:
    ///   - product: The product to remove
    ///   - list: The shopping list
    func removeProduct(_ product: Product, from list: ShoppingList) {
        list.removeProduct(product)
        try? modelContext.save()
    }
    
    /// Remove a shopping list item
    /// - Parameters:
    ///   - item: The item to remove
    ///   - list: The shopping list
    func removeItem(_ item: ShoppingListItem, from list: ShoppingList) {
        list.removeItem(item)
        modelContext.delete(item)
        try? modelContext.save()
    }
    
    /// Toggle the checked state of a product in a specific list
    /// - Parameters:
    ///   - product: The product to toggle
    ///   - list: The shopping list
    func toggleProductChecked(_ product: Product, in list: ShoppingList) {
        list.toggleProductChecked(product)
        try? modelContext.save()
    }
    
    /// Toggle the checked state of a product in a specific list by list ID
    /// - Parameters:
    ///   - product: The product to toggle
    ///   - listId: The ID of the shopping list
    func toggleProductChecked(_ product: Product, in listId: UUID) {
        let descriptor = FetchDescriptor<ShoppingList>(
            predicate: #Predicate { $0.id == listId }
        )
        guard let list = try? modelContext.fetch(descriptor).first else { return }
        list.toggleProductChecked(product)
        try? modelContext.save()
    }
    
    /// Check if a product is checked in a specific list by list ID
    /// - Parameters:
    ///   - product: The product to check
    ///   - listId: The ID of the shopping list
    /// - Returns: True if the product is checked in the list
    func isProductChecked(_ product: Product, in listId: UUID) -> Bool {
        let descriptor = FetchDescriptor<ShoppingList>(
            predicate: #Predicate { $0.id == listId }
        )
        guard let list = try? modelContext.fetch(descriptor).first else { return false }
        return list.isProductChecked(product)
    }
    
    /// Clear all checked items from a specific list
    /// - Parameter listId: The ID of the list to clear
    func clearCheckedItems(in listId: UUID) {
        let descriptor = FetchDescriptor<ShoppingList>(
            predicate: #Predicate { $0.id == listId }
        )
        guard let list = try? modelContext.fetch(descriptor).first else { return }
        list.clearCheckedItems()
        try? modelContext.save()
    }
    
    // MARK: - Query Methods
    
    /// Fetch all shopping lists
    /// - Returns: Array of all shopping lists
    func fetchAllLists() -> [ShoppingList] {
        let descriptor = FetchDescriptor<ShoppingList>(sortBy: [SortDescriptor(\.name)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    /// Fetch lists containing a specific product
    /// - Parameter product: The product to search for
    /// - Returns: Array of shopping lists containing the product
    func fetchLists(containing product: Product) -> [ShoppingList] {
        let allLists = fetchAllLists()
        return allLists.filter { list in
            list.products.contains { $0.id == product.id }
        }
    }
}
