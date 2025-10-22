//
//  DataPersistence.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 21.10.2025.
//

import Foundation

// MARK: - Data Persistence Protocol

/// Protocol defining data persistence operations
/// Allows for easy swapping of persistence implementations (UserDefaults, CoreData, SwiftData, etc.)
protocol DataPersistenceProtocol {
    
    /// Save data to persistent storage
    /// - Parameter key: Storage key identifier
    /// - Parameter data: Data to persist
    func save<T: Codable>(_ data: T, forKey key: String)
    
    /// Load data from persistent storage
    /// - Parameter key: Storage key identifier
    /// - Returns: Decoded data or nil if not found
    func load<T: Codable>(forKey key: String) -> T?
    
    /// Delete data from persistent storage
    /// - Parameter key: Storage key identifier
    func delete(forKey key: String)
}

// MARK: - Mock Implementation

/// Mock implementation for development and testing
/// TODO: Replace with actual persistence (UserDefaults, CoreData, or SwiftData)
class MockDataPersistence: DataPersistenceProtocol {
    
    /// In-memory storage for development
    private var storage: [String: Data] = [:]
    
    func save<T: Codable>(_ data: T, forKey key: String) {
        guard let encoded = try? JSONEncoder().encode(data) else {
            print("❌ Failed to encode data for key: \(key)")
            return
        }
        storage[key] = encoded
        print("✅ Saved \(type(of: data)) for key: \(key)")
    }
    
    func load<T: Codable>(forKey key: String) -> T? {
        guard let data = storage[key],
              let decoded = try? JSONDecoder().decode(T.self, from: data) else {
            print("⚠️ No data found for key: \(key)")
            return nil
        }
        print("✅ Loaded \(T.self) for key: \(key)")
        return decoded
    }
    
    func delete(forKey key: String) {
        storage.removeValue(forKey: key)
        print("✅ Deleted data for key: \(key)")
    }
}

// MARK: - Storage Keys

/// Centralized storage keys for data persistence
enum StorageKeys {
    static let products = "com.punguta.products"
    static let shoppingLists = "com.punguta.shoppingLists"
    static let stores = "com.punguta.stores"
    static let categories = "com.punguta.categories"
}
