//
//  StoreProductView.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 20.10.2025.
//

import Foundation

// MARK: - Category Product Group

/// Groups products under a single category for display
/// Used to organize products by category within a store view
struct CategoryProductGroup: Identifiable, Hashable {
    
    /// Uses categoryId as the unique identifier
    var id: UUID { categoryId }
    
    /// The category ID for this group
    let categoryId: UUID
    
    /// Display name of the category
    let categoryName: String
    
    /// Products belonging to this category
    let products: [Product]
}

// MARK: - Store Product View

/// View model for displaying products organized by a specific store's layout
///
/// **Purpose**: Transforms the global product list into a store-specific view
/// - Filters products to show only those in the store's categories
/// - Orders products according to the store's category arrangement
/// - Useful for shopping at a specific store
struct StoreProductView {
    
    // MARK: Properties
    
    /// ID of the store this view represents
    let storeId: UUID
    
    /// Name of the store
    let storeName: String
    
    /// Products organized by category in store order
    let productsByCategory: [CategoryProductGroup]
    
    // MARK: Factory Method
    
    /// Creates a store-specific product view from global data
    ///
    /// **Algorithm**:
    /// 1. Filter products to those in store's categories
    /// 2. Group filtered products by category
    /// 3. Order groups according to store's category order
    /// 4. Sort products alphabetically within each group
    ///
    /// - Parameters:
    ///   - store: The store to create view for
    ///   - products: All available products
    ///   - categories: All available categories
    /// - Returns: Store-specific product view
    static func create(
        for store: Store,
        from products: [Product],
        using categories: [Category]
    ) -> StoreProductView {
        // Create quick lookup map for categories
        let categoryMap = Dictionary(
            uniqueKeysWithValues: categories.map { ($0.id, $0) }
        )
        
        // Filter products that belong to categories in this store
        let storeCategories = Set(store.categoryOrder)
        let filteredProducts = products.filter { storeCategories.contains($0.categoryId) }
        
        // Group products by category, maintaining store's category order
        var productsByCategory: [CategoryProductGroup] = []
        
        for categoryId in store.categoryOrder {
            let categoryProducts = filteredProducts.filter { $0.categoryId == categoryId }
            
            // Only include categories that have products
            if !categoryProducts.isEmpty, let category = categoryMap[categoryId] {
                productsByCategory.append(
                    CategoryProductGroup(
                        categoryId: categoryId,
                        categoryName: category.name,
                        // Sort products alphabetically within category
                        products: categoryProducts.sorted { $0.name < $1.name }
                    )
                )
            }
        }
        
        return StoreProductView(
            storeId: store.id,
            storeName: store.name,
            productsByCategory: productsByCategory
        )
    }
    
    // MARK: Computed Properties
    
    /// Total count of products available at this store
    var totalProductCount: Int {
        productsByCategory.reduce(0) { $0 + $1.products.count }
    }
    
    /// Count of checked (purchased) products
    var checkedProductCount: Int {
        productsByCategory.reduce(0) { sum, group in
            sum + group.products.filter { $0.isChecked }.count
        }
    }
}
