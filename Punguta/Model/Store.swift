//
//  Store.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 20.10.2025.
//

import Foundation
import CoreLocation

// MARK: - Store Type

/// Represents different types of retail stores
/// Each type has predefined default categories that match typical store layouts
enum StoreType: String, Codable, CaseIterable {
    case grocery = "Grocery"
    case pharmacy = "Pharmacy"
    case hardware = "Hardware"
    case hypermarket = "Hypermarket"
    
    /// Returns default category names for this store type
    /// These categories are automatically suggested when creating a new store
    /// They reflect typical store layouts to help organize shopping
    var defaultCategoryNames: [String] {
        switch self {
        case .grocery:
            return ["Produce", "Dairy", "Meat", "Bakery", "Beverages", "Frozen", "Pantry", "Snacks"]
        case .pharmacy:
            return ["Personal Care", "Medicine", "Vitamins", "First Aid", "Beauty"]
        case .hardware:
            return ["Tools", "Hardware", "Paint", "Electrical", "Plumbing", "Garden"]
        case .hypermarket:
            return ["Beverages", "Snacks", "Dairy", "Bakery", "Personal Care"]
        }
    }
}

// MARK: - Store Location

/// Represents the geographic location of a store
/// Stores coordinates and optional address for display and navigation
struct StoreLocation: Codable, Hashable {
    
    // MARK: Properties
    
    /// Geographic latitude
    let latitude: Double
    
    /// Geographic longitude
    let longitude: Double
    
    /// Optional human-readable address
    let address: String?
    
    // MARK: Computed Properties
    
    /// Converts to CoreLocation coordinate for map integration
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    // MARK: Initializers
    
    /// Initialize with latitude and longitude
    init(latitude: Double, longitude: Double, address: String? = nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
    }
    
    /// Initialize with CoreLocation coordinate
    init(coordinate: CLLocationCoordinate2D, address: String? = nil) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.address = address
    }
}

// MARK: - Store

/// Represents a physical retail store with location and category organization
///
/// **Key Features**:
/// - Each store has a specific type (grocery, pharmacy, etc.)
/// - Maintains a custom category order matching the store's physical layout
/// - Helps organize shopping by showing products in the order you'll encounter them
struct Store: Identifiable, Codable, Hashable {
    
    // MARK: Properties
    
    /// Unique identifier for the store
    let id: UUID
    
    /// Display name of the store (e.g., "Whole Foods", "CVS Pharmacy")
    var name: String
    
    /// Type of store, determines default categories
    var type: StoreType
    
    /// Geographic location of the store
    var location: StoreLocation
    
    /// Ordered array of category IDs representing store layout
    /// Can be customized by user to match actual store organization
    var categoryOrder: [UUID]
    
    // MARK: Initializer
    
    init(id: UUID = UUID(), name: String, type: StoreType, location: StoreLocation, categoryOrder: [UUID] = []) {
        self.id = id
        self.name = name
        self.type = type
        self.location = location
        self.categoryOrder = categoryOrder
    }
    
    // MARK: Factory Method
    
    /// Creates a new store with default categories for its type
    /// Matches category names to IDs from the available categories
    ///
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
        // Create name-to-ID mapping for quick lookup
        let categoryMap = Dictionary(
            uniqueKeysWithValues: availableCategories.map { ($0.name, $0.id) }
        )
        
        // Map default category names to their IDs
        let defaultCategoryIds = type.defaultCategoryNames.compactMap { categoryMap[$0] }
        
        return Store(
            name: name,
            type: type,
            location: location,
            categoryOrder: defaultCategoryIds
        )
    }
    
    // MARK: Mutations
    
    /// Add a new category to the store's category order
    /// - Parameter categoryId: The category ID to add
    /// - Note: Does nothing if category already exists
    mutating func addCategory(_ categoryId: UUID) {
        guard !categoryOrder.contains(categoryId) else { return }
        categoryOrder.append(categoryId)
    }
    
    /// Remove a category from the store's category order
    /// - Parameter categoryId: The category ID to remove
    mutating func removeCategory(_ categoryId: UUID) {
        categoryOrder.removeAll { $0 == categoryId }
    }
    
    /// Replace the entire category order with a new arrangement
    /// - Parameter newOrder: The new category order
    /// - Note: Used when user manually reorders categories
    mutating func reorderCategories(_ newOrder: [UUID]) {
        categoryOrder = newOrder
    }
}
