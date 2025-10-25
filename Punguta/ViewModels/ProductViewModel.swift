//
//  ProductViewModel.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 22.10.2025.
//

import Foundation
import SwiftUI
import SwiftData
import Combine

// MARK: - Product View Model

/// Manages products using SwiftData
///
/// **Responsibilities**:
/// - CRUD operations for products via ModelContext
/// - Product categorization and auto-suggestions
/// - Product search and filtering
///
/// **Design Pattern**: MVVM with SwiftData
/// - Lightweight business logic coordinator
/// - SwiftData handles persistence automatically
/// - Uses ModelContext for database operations
@MainActor
class ProductViewModel: ObservableObject {
    
    // MARK: Private Properties
    
    /// SwiftData model context for database operations
    private let modelContext: ModelContext
    
    // MARK: Initializer
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Product Operations
    
    /// Create a new product
    /// - Parameters:
    ///   - name: Product name
    ///   - category: Category the product belongs to (optional)
    ///   - quantity: Amount and unit
    /// - Returns: The newly created product
    @discardableResult
    func createProduct(name: String, category: Category?, quantity: ProductQuantity) -> Product {
        let product = Product(name: name, category: category, quantity: quantity)
        modelContext.insert(product)
        try? modelContext.save()
        return product
    }
    
    /// Update a product (SwiftData tracks changes automatically)
    /// - Parameter product: The product to update
    func updateProduct(_ product: Product) {
        try? modelContext.save()
    }
    
    /// Delete a product globally
    /// - Parameter product: The product to delete
    /// - Note: Cascade delete will remove associated ShoppingListItems
    func deleteProduct(_ product: Product) {
        modelContext.delete(product)
        try? modelContext.save()
    }
    
    /// Update a product's quantity
    /// - Parameters:
    ///   - product: The product to update
    ///   - newQuantity: New quantity to set
    func updateProductQuantity(_ product: Product, newQuantity: ProductQuantity) {
        product.updateQuantity(newQuantity)
        try? modelContext.save()
    }
    
    // MARK: - Query Methods
    
    /// Fetch all products
    /// - Returns: Array of all products
    func fetchAllProducts() -> [Product] {
        let descriptor = FetchDescriptor<Product>(sortBy: [SortDescriptor(\.name)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    /// Get products filtered by category
    /// - Parameter category: The category to filter by
    /// - Returns: Array of products in that category
    func fetchProducts(inCategory category: Category) -> [Product] {
        let categoryId = category.id
        let descriptor = FetchDescriptor<Product>(
            predicate: #Predicate<Product> { product in
                product.category?.id == categoryId
            },
            sortBy: [SortDescriptor(\.name)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    /// Search products by name
    /// - Parameter query: Search text
    /// - Returns: Array of products whose names contain the query
    func searchProducts(_ query: String) -> [Product] {
        if query.isEmpty {
            return fetchAllProducts()
        }
        
        let descriptor = FetchDescriptor<Product>(
            predicate: #Predicate { product in
                product.name.localizedStandardContains(query)
            },
            sortBy: [SortDescriptor(\.name)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    // MARK: - Auto-Categorization
    
    /// Suggest a category for a product based on its name
    ///
    /// **Smart Matching Algorithm**:
    /// 1. Convert product name to lowercase
    /// 2. Find all categories with matching keywords
    /// 3. Prioritize the longest/most specific keyword match
    /// 4. This ensures "hammer" matches "hammer" (Tools) not "ham" (Meat)
    ///
    /// - Parameters:
    ///   - productName: Name of the product
    ///   - categories: Available categories to search
    /// - Returns: Category if match found, nil otherwise
    func suggestCategory(for productName: String, from categories: [Category]) -> Category? {
        let lowercaseName = productName.lowercased().trimmingCharacters(in: .whitespaces)
        
        // Return nil for empty names
        guard !lowercaseName.isEmpty else {
            return nil
        }
        
        // Find all matching categories with their best matching keyword length
        var matches: [(category: Category, keywordLength: Int)] = []
        
        for category in categories {
            for keyword in category.keywords {
                if lowercaseName.contains(keyword) {
                    // Keep track of the longest keyword that matches for this category
                    if let existingMatch = matches.first(where: { $0.category.id == category.id }) {
                        // Update if this keyword is longer (more specific)
                        if keyword.count > existingMatch.keywordLength {
                            matches.removeAll { $0.category.id == category.id }
                            matches.append((category, keyword.count))
                        }
                    } else {
                        matches.append((category, keyword.count))
                    }
                }
            }
        }
        
        // Return the category with the longest matching keyword (most specific match)
        let bestMatch = matches.max { $0.keywordLength < $1.keywordLength }
        return bestMatch?.category
    }
}
