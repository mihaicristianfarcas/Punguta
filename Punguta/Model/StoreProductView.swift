//
//  StoreProductView.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 20.10.2025.
//

import Foundation

/// Helper structure for displaying products filtered by store
/// Shows only products that match the store's categories, organized by category order
struct CategoryProductGroup: Identifiable, Hashable {
    var id: UUID { categoryId }
    let categoryId: UUID
    let categoryName: String
    let products: [Product]
}

struct StoreProductView {
    let storeId: UUID
    let storeName: String
    let productsByCategory: [CategoryProductGroup]
    
    /// Filters products from shopping lists based on store's categories
    /// - Parameters:
    ///   - store: The store to filter for
    ///   - products: All products from shopping lists
    ///   - categories: All available categories
    /// - Returns: Products organized by the store's category order
    static func create(
        for store: Store,
        from products: [Product],
        using categories: [Category]
    ) -> StoreProductView {
        let categoryMap = Dictionary(uniqueKeysWithValues: categories.map { ($0.id, $0) })
        
        // Filter products that belong to categories in this store
        let storeCategories = Set(store.categoryOrder)
        let filteredProducts = products.filter { storeCategories.contains($0.categoryId) }
        
        // Group products by category, maintaining store's category order
        var productsByCategory: [CategoryProductGroup] = []
        
        for categoryId in store.categoryOrder {
            let categoryProducts = filteredProducts.filter { $0.categoryId == categoryId }
            
            if !categoryProducts.isEmpty, let category = categoryMap[categoryId] {
                productsByCategory.append(
                    CategoryProductGroup(
                        categoryId: categoryId,
                        categoryName: category.name,
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
