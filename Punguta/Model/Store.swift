//
//  Store.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 20.10.2025.
//

import Foundation
import CoreLocation

enum StoreType: String, Codable, CaseIterable {
    case grocery = "Grocery"
    case pharmacy = "Pharmacy"
    case hardware = "Hardware"
    case convenience = "Convenience"
    
    /// Returns default category names for this store type
    /// These categories are automatically suggested when creating a new store
    var defaultCategoryNames: [String] {
        switch self {
        case .grocery:
            return ["Produce", "Dairy", "Meat", "Bakery", "Beverages", "Frozen", "Pantry", "Snacks"]
        case .pharmacy:
            return ["Personal Care", "Medicine", "Vitamins", "First Aid", "Beauty"]
        case .hardware:
            return ["Tools", "Hardware", "Paint", "Electrical", "Plumbing", "Garden"]
        case .convenience:
            return ["Beverages", "Snacks", "Dairy", "Bakery", "Personal Care"]
        }
    }
}

struct StoreLocation: Codable, Hashable {
    let latitude: Double
    let longitude: Double
    let address: String?
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(latitude: Double, longitude: Double, address: String? = nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
    }
    
    init(coordinate: CLLocationCoordinate2D, address: String? = nil) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.address = address
    }
}

struct Store: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var type: StoreType
    var location: StoreLocation
    var categoryOrder: [UUID] // Array of category IDs in user-defined order (can be reordered or extended by user)
    
    init(id: UUID = UUID(), name: String, type: StoreType, location: StoreLocation, categoryOrder: [UUID] = []) {
        self.id = id
        self.name = name
        self.type = type
        self.location = location
        self.categoryOrder = categoryOrder
    }
    
    /// Creates a new store with default categories for its type
    /// - Parameters:
    ///   - name: Store name
    ///   - type: Store type (determines default categories)
    ///   - location: Store location
    ///   - availableCategories: All available categories to choose from
    /// - Returns: Store initialized with default category order
    static func create(
        name: String,
        type: StoreType,
        location: StoreLocation,
        from availableCategories: [Category]
    ) -> Store {
        let categoryMap = Dictionary(uniqueKeysWithValues: availableCategories.map { ($0.name, $0.id) })
        let defaultCategoryIds = type.defaultCategoryNames.compactMap { categoryMap[$0] }
        
        return Store(
            name: name,
            type: type,
            location: location,
            categoryOrder: defaultCategoryIds
        )
    }
    
    /// Adds a new category to the store's category order
    mutating func addCategory(_ categoryId: UUID) {
        if !categoryOrder.contains(categoryId) {
            categoryOrder.append(categoryId)
        }
    }
    
    /// Removes a category from the store's category order
    mutating func removeCategory(_ categoryId: UUID) {
        categoryOrder.removeAll { $0 == categoryId }
    }
    
    /// Reorders categories
    mutating func reorderCategories(_ newOrder: [UUID]) {
        categoryOrder = newOrder
    }
}
