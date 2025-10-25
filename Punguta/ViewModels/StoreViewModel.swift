//
//  StoreViewModel.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 20.10.2025.
//

import Foundation
import CoreLocation
import SwiftUI
import SwiftData
import Combine

// MARK: - Store View Model

/// Manages stores using SwiftData
///
/// **Responsibilities**:
/// - CRUD operations for stores via ModelContext
/// - Store category management
/// - Category lookup and organization
///
/// **Design Pattern**: MVVM with SwiftData
/// - Lightweight business logic coordinator
/// - SwiftData handles persistence automatically
/// - Uses ModelContext for database operations
@MainActor
class StoreViewModel: ObservableObject {
    
    // MARK: Private Properties
    
    /// SwiftData model context for database operations
    private let modelContext: ModelContext
    
    // MARK: Initializer
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Store Operations
    
    /// Create a new store
    /// - Parameters:
    ///   - name: Store name
    ///   - type: Store type (determines default categories)
    ///   - location: Store location
    ///   - categoryOrder: Optional custom category order
    /// - Returns: The newly created store
    @discardableResult
    func createStore(name: String, type: StoreType, location: StoreLocation, categoryOrder: [UUID]? = nil) -> Store {
        let categories = fetchAllCategories()
        let store: Store
        
        if let customOrder = categoryOrder {
            store = Store(name: name, type: type, location: location, categoryOrder: customOrder)
        } else {
            store = Store.create(name: name, type: type, location: location, from: categories)
        }
        
        modelContext.insert(store)
        try? modelContext.save()
        return store
    }
    
    /// Update a store (SwiftData tracks changes automatically)
    /// - Parameter store: The store to update
    func updateStore(_ store: Store) {
        try? modelContext.save()
    }
    
    /// Delete a store
    /// - Parameter store: The store to delete
    func deleteStore(_ store: Store) {
        modelContext.delete(store)
        try? modelContext.save()
    }
    
    /// Delete stores
    /// - Parameter stores: Array of stores to delete
    func deleteStores(_ stores: [Store]) {
        for store in stores {
            modelContext.delete(store)
        }
        try? modelContext.save()
    }
    
    /// Update the category order for a specific store
    /// - Parameters:
    ///   - store: The store to update
    ///   - newOrder: New category order array
    func updateStoreCategoryOrder(_ store: Store, newOrder: [UUID]) {
        store.reorderCategories(newOrder)
        try? modelContext.save()
    }
    
    // MARK: - Query Methods
    
    /// Fetch all stores
    /// - Returns: Array of all stores
    func fetchAllStores() -> [Store] {
        let descriptor = FetchDescriptor<Store>(sortBy: [SortDescriptor(\.name)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    /// Fetch all categories
    /// - Returns: Array of all categories
    func fetchAllCategories() -> [Category] {
        let descriptor = FetchDescriptor<Category>(sortBy: [SortDescriptor(\.name)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    /// Find a category by ID
    /// - Parameter id: The category ID
    /// - Returns: The category if found, nil otherwise
    func fetchCategory(byId id: UUID) -> Category? {
        let descriptor = FetchDescriptor<Category>(
            predicate: #Predicate { $0.id == id }
        )
        return try? modelContext.fetch(descriptor).first
    }
    
    /// Get all categories for a specific store in order
    /// - Parameter store: The store
    /// - Returns: Ordered array of categories matching the store's layout
    func fetchCategories(for store: Store) -> [Category] {
        let allCategories = fetchAllCategories()
        let categoryMap = Dictionary(uniqueKeysWithValues: allCategories.map { ($0.id, $0) })
        return store.categoryOrder.compactMap { categoryMap[$0] }
    }
    
    /// Get stores of a specific type
    /// - Parameter type: The store type to filter by
    /// - Returns: Array of stores of that type
    func fetchStores(ofType type: StoreType) -> [Store] {
        let descriptor = FetchDescriptor<Store>(
            predicate: #Predicate { $0.type == type },
            sortBy: [SortDescriptor(\.name)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
}
