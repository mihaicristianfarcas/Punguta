//
//  ProductViewModel.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 22.10.2025.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Product View Model

/// Manages products independently from shopping lists
///
/// **Responsibilities**:
/// - CRUD operations for products
/// - Product categorization and auto-suggestions
/// - Product search and filtering
/// - Data persistence coordination
///
/// **Design Pattern**: MVVM (Model-View-ViewModel)
/// - Separates product business logic from UI
/// - Provides reactive data binding via @Published
/// - Ensures main thread execution with @MainActor
/// - Can be shared across multiple views
@MainActor
class ProductViewModel: ObservableObject {
    
    // MARK: Published Properties
    
    /// All products in the app (global, shared across lists)
    @Published var products: [Product] = []
    
    // MARK: Private Properties
    
    /// Data persistence handler
    private let persistence: DataPersistenceProtocol
    
    // MARK: Initializer
    
    init(persistence: DataPersistenceProtocol = MockDataPersistence()) {
        self.persistence = persistence
        loadProducts()
    }
    
    // MARK: - Product Operations
    
    /// Create a new product
    /// - Parameters:
    ///   - name: Product name
    ///   - categoryId: Category the product belongs to
    ///   - quantity: Amount and unit
    /// - Returns: The ID of the newly created product
    @discardableResult
    func createProduct(name: String, categoryId: UUID, quantity: ProductQuantity) -> UUID {
        let product = Product(name: name, categoryId: categoryId, quantity: quantity)
        products.append(product)
        saveProducts()
        objectWillChange.send()
        return product.id
    }
    
    /// Update an existing product
    /// - Parameter product: The updated product
    func updateProduct(_ product: Product) {
        guard let index = products.firstIndex(where: { $0.id == product.id }) else {
            return
        }
        products[index] = product
        saveProducts()
        objectWillChange.send()
    }
    
    /// Delete a product globally
    /// - Parameter product: The product to delete
    /// - Note: Caller is responsible for removing product from shopping lists
    func deleteProduct(_ product: Product) {
        products.removeAll { $0.id == product.id }
        saveProducts()
        objectWillChange.send()
    }
    
    /// Update a product's quantity
    /// - Parameters:
    ///   - productId: ID of the product to update
    ///   - newQuantity: New quantity to set
    func updateProductQuantity(productId: UUID, newQuantity: ProductQuantity) {
        guard let index = products.firstIndex(where: { $0.id == productId }) else {
            return
        }
        products[index].updateQuantity(newQuantity)
        saveProducts()
        objectWillChange.send()
    }
    
    // MARK: - Query Methods
    
    /// Find a product by ID
    /// - Parameter id: The product ID
    /// - Returns: The product if found, nil otherwise
    func product(for id: UUID) -> Product? {
        products.first { $0.id == id }
    }
    
    /// Get products filtered by category
    /// - Parameter categoryId: The category to filter by
    /// - Returns: Array of products in that category
    func products(inCategory categoryId: UUID) -> [Product] {
        products.filter { $0.categoryId == categoryId }
    }
    
    /// Get products matching a search query
    /// - Parameter query: Search text
    /// - Returns: Array of products whose names contain the query
    func searchProducts(_ query: String) -> [Product] {
        if query.isEmpty {
            return products
        }
        return products.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
    
    // MARK: - Auto-Categorization
    
    /// Suggest a category for a product based on its name
    ///
    /// **Algorithm**:
    /// 1. Convert product name to lowercase
    /// 2. Check each category's keywords
    /// 3. Return first category with a matching keyword
    ///
    /// - Parameters:
    ///   - productName: Name of the product
    ///   - categories: Available categories to search
    /// - Returns: Category ID if match found, nil otherwise
    func suggestCategory(for productName: String, categories: [Category]) -> UUID? {
        let lowercaseName = productName.lowercased()
        
        // Find best matching category by keyword
        for category in categories {
            for keyword in category.keywords {
                if lowercaseName.contains(keyword) {
                    return category.id
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Data Persistence
    
    /// Load products from persistent storage
    private func loadProducts() {
        // Try to load persisted data
        if let savedProducts: [Product] = persistence.load(forKey: StorageKeys.products) {
            self.products = savedProducts
        } else {
            // No saved data, load sample products for first launch
            loadSampleProducts()
        }
    }
    
    /// Save products to persistent storage
    private func saveProducts() {
        persistence.save(products, forKey: StorageKeys.products)
    }
    
    // MARK: - Sample Data
    
    /// Load sample products for demonstration and first-time app launch
    private func loadSampleProducts() {
        let categories = Category.defaultCategories
        
        // Find categories for sample products
        guard let produceCategory = categories.first(where: { $0.name == "Produce" }),
              let dairyCategory = categories.first(where: { $0.name == "Dairy" }),
              let meatCategory = categories.first(where: { $0.name == "Meat" }),
              let bakeryCategory = categories.first(where: { $0.name == "Bakery" }),
              let beveragesCategory = categories.first(where: { $0.name == "Beverages" }) else {
            return
        }
        
        // Create sample products
        products = [
            Product(
                name: "Bananas",
                categoryId: produceCategory.id,
                quantity: ProductQuantity(amount: 1, unit: "kg")
            ),
            Product(
                name: "Milk",
                categoryId: dairyCategory.id,
                quantity: ProductQuantity(amount: 2, unit: "L")
            ),
            Product(
                name: "Chicken Breast",
                categoryId: meatCategory.id,
                quantity: ProductQuantity(amount: 500, unit: "g")
            ),
            Product(
                name: "Apples",
                categoryId: produceCategory.id,
                quantity: ProductQuantity(amount: 1.5, unit: "kg")
            ),
            Product(
                name: "Yogurt",
                categoryId: dairyCategory.id,
                quantity: ProductQuantity(amount: 4, unit: "pcs")
            ),
            Product(
                name: "Bread",
                categoryId: bakeryCategory.id,
                quantity: ProductQuantity(amount: 1, unit: "pcs")
            ),
            Product(
                name: "Orange Juice",
                categoryId: beveragesCategory.id,
                quantity: ProductQuantity(amount: 1, unit: "L")
            )
        ]
        
        // Save sample products
        saveProducts()
    }
}
