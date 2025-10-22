//
//  ListViewModel.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 21.10.2025.
//

import Foundation
import SwiftUI
import Combine

// MARK: - List View Model

/// Manages shopping lists
///
/// **Responsibilities**:
/// - CRUD operations for shopping lists
/// - List-product relationship management
/// - Data persistence coordination
///
/// **Design Pattern**: MVVM (Model-View-ViewModel)
/// - Separates business logic from UI
/// - Provides reactive data binding via @Published
/// - Ensures main thread execution with @MainActor
/// - Works in conjunction with ProductViewModel for product management
@MainActor
class ListViewModel: ObservableObject {
    
    // MARK: Published Properties
    
    /// All shopping lists in the app
    @Published var shoppingLists: [ShoppingList] = []
    
    // MARK: Private Properties
    
    /// Data persistence handler
    private let persistence: DataPersistenceProtocol
    
    /// Reference to ProductViewModel for product operations
    /// This creates a coordinated relationship between lists and products
    private var productViewModel: ProductViewModel?
    
    // MARK: Initializer
    
    init(persistence: DataPersistenceProtocol = MockDataPersistence()) {
        self.persistence = persistence
        loadData()
    }
    
    /// Set the product view model for coordinated operations
    /// - Parameter productViewModel: The shared ProductViewModel instance
    func setProductViewModel(_ productViewModel: ProductViewModel) {
        self.productViewModel = productViewModel
    }
    
    // MARK: - Shopping List Operations
    
    /// Create a new shopping list
    /// - Parameters:
    ///   - name: Display name for the list
    ///   - productIds: Optional array of product IDs to include
    func createList(name: String, productIds: [UUID] = []) {
        let list = ShoppingList(name: name, productIds: productIds)
        shoppingLists.append(list)
        saveLists()
    }
    
    /// Update an existing shopping list
    /// - Parameter list: The updated list
    func updateList(_ list: ShoppingList) {
        guard let index = shoppingLists.firstIndex(where: { $0.id == list.id }) else {
            return
        }
        shoppingLists[index] = list
        saveLists()
        objectWillChange.send()
    }
    
    /// Delete a shopping list
    /// - Parameter list: The list to delete
    /// - Note: Does not delete the products themselves
    func deleteList(_ list: ShoppingList) {
        shoppingLists.removeAll { $0.id == list.id }
        saveLists()
    }
    
    /// Delete shopping lists at specific offsets
    /// - Parameter offsets: IndexSet of lists to delete
    /// - Note: Used for swipe-to-delete in List views
    func deleteList(at offsets: IndexSet) {
        shoppingLists.remove(atOffsets: offsets)
        saveLists()
    }
    
    // MARK: - List-Product Relationship
    
    /// Add a product to a shopping list
    /// - Parameters:
    ///   - productId: ID of the product to add
    ///   - listId: ID of the shopping list
    func addProduct(_ productId: UUID, toList listId: UUID) {
        guard let index = shoppingLists.firstIndex(where: { $0.id == listId }) else {
            return
        }
        shoppingLists[index].addProduct(productId)
        saveLists()
    }
    
    /// Remove a product from a shopping list
    /// - Parameters:
    ///   - productId: ID of the product to remove
    ///   - listId: ID of the shopping list
    /// - Note: Does not delete the product globally
    func removeProduct(_ productId: UUID, fromList listId: UUID) {
        guard let index = shoppingLists.firstIndex(where: { $0.id == listId }) else {
            return
        }
        shoppingLists[index].removeProduct(productId)
        saveLists()
    }
    
    /// Remove a product from all shopping lists
    /// - Parameter productId: ID of the product to remove
    /// - Note: Called when a product is deleted globally
    func removeProductFromAllLists(_ productId: UUID) {
        for index in shoppingLists.indices {
            shoppingLists[index].removeProduct(productId)
        }
        saveLists()
    }
    
    /// Toggle the checked state of a product in a specific list
    /// - Parameters:
    ///   - productId: ID of the product to toggle
    ///   - listId: ID of the shopping list
    func toggleProductChecked(_ productId: UUID, inList listId: UUID) {
        guard let index = shoppingLists.firstIndex(where: { $0.id == listId }) else {
            return
        }
        shoppingLists[index].toggleProductChecked(productId)
        saveLists()
        objectWillChange.send()
    }
    
    // MARK: - Query Methods
    
    /// Get a specific shopping list by ID
    /// - Parameter id: The list ID
    /// - Returns: The shopping list if found, nil otherwise
    func list(for id: UUID) -> ShoppingList? {
        shoppingLists.first { $0.id == id }
    }
    
    // MARK: - Data Persistence
    
    /// Load shopping lists from persistent storage
    private func loadData() {
        // Try to load persisted lists
        if let savedLists: [ShoppingList] = persistence.load(forKey: StorageKeys.shoppingLists) {
            self.shoppingLists = savedLists
        } else {
            // No saved data, load sample lists for first launch
            loadSampleLists()
        }
    }
    
    /// Save shopping lists to persistent storage
    private func saveLists() {
        persistence.save(shoppingLists, forKey: StorageKeys.shoppingLists)
    }
    
    // MARK: - Sample Data
    
    /// Load sample shopping lists for demonstration and first-time app launch
    /// Creates sample lists that reference products from ProductViewModel
    private func loadSampleLists() {
        // Sample lists will be populated with product IDs after products are loaded
        // This is coordinated through ContentView or app initialization
        shoppingLists = [
            ShoppingList(name: "Weekly Groceries", productIds: []),
            ShoppingList(name: "Weekend BBQ", productIds: [])
        ]
        
        // Save sample lists
        saveLists()
    }
    
    /// Initialize sample lists with actual product IDs
    /// - Parameter products: Array of products to reference
    /// - Note: Called after ProductViewModel has loaded sample products
    func initializeSampleLists(with products: [Product]) {
        guard shoppingLists.count >= 2, products.count >= 5 else { return }
        
        // Update first list with some products
        shoppingLists[0].productIds = [
            products[0].id,  // Bananas
            products[1].id,  // Milk
            products[2].id   // Chicken Breast
        ]
        
        // Update second list with different products
        shoppingLists[1].productIds = [
            products[2].id,  // Chicken Breast
            products[3].id   // Apples
        ]
        
        saveLists()
    }
}
