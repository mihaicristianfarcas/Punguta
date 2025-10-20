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

@MainActor
class StoreViewModel: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
    
    @Published var stores: [Store] = []
    @Published var categories: [Category] = Category.defaultCategories
    
    init() {
        // Load sample data for testing
        loadSampleData()
    }
    
    // MARK: - CRUD Operations
    
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
    
    func updateStore(_ store: Store) {
        if let index = stores.firstIndex(where: { $0.id == store.id }) {
            stores[index] = store
            saveStores()
        }
    }
    
    func deleteStore(_ store: Store) {
        stores.removeAll { $0.id == store.id }
        saveStores()
    }
    
    func deleteStores(at offsets: IndexSet) {
        stores.remove(atOffsets: offsets)
        saveStores()
    }
    
    // MARK: - Category Helpers
    
    func category(for id: UUID) -> Category? {
        categories.first { $0.id == id }
    }
    
    func categories(for store: Store) -> [Category] {
        store.categoryOrder.compactMap { categoryId in
            categories.first { $0.id == categoryId }
        }
    }
    
    // MARK: - Persistence
    
    private func saveStores() {
        // TODO: Implement actual persistence (UserDefaults, CoreData, or SwiftData)
        print("Stores saved: \(stores.count)")
    }
    
    private func loadStores() {
        // TODO: Implement actual loading
    }
    
    // MARK: - Sample Data
    
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
            Store.create(name: "Auchan", type: .grocery, location: sampleLocation1, from: categories),
            Store.create(name: "Mega Image", type: .convenience, location: sampleLocation2, from: categories)
        ]
    }
}

