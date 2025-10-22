//
//  StoreViewModel.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 20.10.2025.
//

import Foundation
import CoreLocation
import Combine
import SwiftUI

// MARK: - Store View Model

/// Manages stores and their categories
///
/// **Responsibilities**:
/// - CRUD operations for stores
/// - Store category management
/// - Category lookup and organization
/// - Data persistence coordination
///
/// **Design Pattern**: MVVM (Model-View-ViewModel)
@MainActor
class StoreViewModel: ObservableObject {
    
    // MARK: Published Properties
    
    /// All stores in the app
    @Published var stores: [Store] = []
    
    /// All available categories
    @Published var categories: [Category] = Category.defaultCategories
    
    // MARK: Private Properties
    
    /// Data persistence handler
    private let persistence: DataPersistenceProtocol
    
    // MARK: Initializer
    
    init(persistence: DataPersistenceProtocol = MockDataPersistence()) {
        self.persistence = persistence
        loadData()
    }
    
    // MARK: - Store Operations
    
    /// Create a new store
    /// - Parameters:
    ///   - name: Store name
    ///   - type: Store type (determines default categories)
    ///   - location: Store location
    ///   - categoryOrder: Optional custom category order, uses type defaults if nil
    func createStore(name: String, type: StoreType, location: StoreLocation, categoryOrder: [UUID]? = nil) {
        let store: Store
        if let customOrder = categoryOrder {
            store = Store(name: name, type: type, location: location, categoryOrder: customOrder)
        } else {
            store = Store.create(name: name, type: type, location: location, from: categories)
        }
        stores.append(store)
        saveStores()
    }
    
    /// Update an existing store
    /// - Parameter store: The updated store
    func updateStore(_ store: Store) {
        guard let index = stores.firstIndex(where: { $0.id == store.id }) else {
            return
        }
        stores[index] = store
        saveStores()
        objectWillChange.send()
    }
    
    /// Delete a store
    /// - Parameter store: The store to delete
    func deleteStore(_ store: Store) {
        stores.removeAll { $0.id == store.id }
        saveStores()
    }
    
    /// Delete stores at specific offsets
    /// - Parameter offsets: IndexSet of stores to delete
    /// - Note: Used for swipe-to-delete in List views
    func deleteStores(at offsets: IndexSet) {
        stores.remove(atOffsets: offsets)
        saveStores()
    }
    
    /// Update the category order for a specific store
    /// - Parameters:
    ///   - storeId: ID of the store to update
    ///   - newOrder: New category order array
    func updateStoreCategoryOrder(storeId: UUID, newOrder: [UUID]) {
        guard let index = stores.firstIndex(where: { $0.id == storeId }) else {
            return
        }
        stores[index].categoryOrder = newOrder
        saveStores()
        objectWillChange.send()
    }
    
    // MARK: - Query Methods
    
    /// Find a category by ID
    /// - Parameter id: The category ID
    /// - Returns: The category if found, nil otherwise
    func category(for id: UUID) -> Category? {
        categories.first { $0.id == id }
    }
    
    /// Get all categories for a specific store in order
    /// - Parameter store: The store
    /// - Returns: Ordered array of categories matching the store's layout
    func categories(for store: Store) -> [Category] {
        store.categoryOrder.compactMap { categoryId in
            categories.first { $0.id == categoryId }
        }
    }
    
    // MARK: - Data Persistence
    
    /// Load all data from persistent storage
    private func loadData() {
        // Try to load persisted data
        if let savedStores: [Store] = persistence.load(forKey: StorageKeys.stores) {
            self.stores = savedStores
        } else {
            // No saved data, load sample data for first launch
            loadSampleData()
        }
    }
    
    /// Save stores to persistent storage
    private func saveStores() {
        persistence.save(stores, forKey: StorageKeys.stores)
    }
    
    // MARK: - Sample Data
    
    /// Load sample data for demonstration and first-time app launch
    /// Creates sample stores to showcase app functionality
    private func loadSampleData() {
        let sampleLocation1 = StoreLocation(
            latitude: 44.4268,
            longitude: 26.1025,
            address: "Bucharest, Romania"
        )
        
        let sampleLocation2 = StoreLocation(
            latitude: 44.4361,
            longitude: 26.0969,
            address: "Calea Victoriei, Bucharest"
        )
        
        stores = [
            Store.create(
                name: "Auchan",
                type: .grocery,
                location: sampleLocation1,
                from: categories
            ),
            Store.create(
                name: "Mega Image",
                type: .hypermarket,
                location: sampleLocation2,
                from: categories
            )
        ]
        
        // Save sample data
        saveStores()
    }
}

