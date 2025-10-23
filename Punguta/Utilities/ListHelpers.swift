//
//  ListHelpers.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 23.10.2025.
//

import Foundation

// MARK: - List Helpers

/// Utility functions for common shopping list operations
/// Following Single Responsibility Principle: Separates list manipulation logic from view logic
struct ListHelpers {
    
    /// Clears all checked items from a specific list
    /// - Parameters:
    ///   - listId: The ID of the list to clear
    ///   - listViewModel: The view model managing the lists
    static func clearCheckedItems(listId: UUID, in listViewModel: ListViewModel) {
        guard var list = listViewModel.shoppingLists.first(where: { $0.id == listId }) else {
            return
        }
        list.checkedProductIds.removeAll()
        listViewModel.updateList(list)
    }
    
    /// Toggles the checked state of a product in a specific list
    /// - Parameters:
    ///   - productId: The ID of the product to toggle
    ///   - listId: The ID of the list containing the product
    ///   - listViewModel: The view model managing the lists
    static func toggleProductChecked(productId: UUID, in listId: UUID, using listViewModel: ListViewModel) {
        guard var list = listViewModel.shoppingLists.first(where: { $0.id == listId }) else {
            return
        }
        list.toggleProductChecked(productId)
        listViewModel.updateList(list)
    }
    
    /// Checks if a product is checked in a specific list
    /// - Parameters:
    ///   - productId: The ID of the product to check
    ///   - listId: The ID of the list
    ///   - listViewModel: The view model managing the lists
    /// - Returns: `true` if the product is checked, `false` otherwise
    static func isProductChecked(productId: UUID, in listId: UUID, using listViewModel: ListViewModel) -> Bool {
        guard let list = listViewModel.shoppingLists.first(where: { $0.id == listId }) else {
            return false
        }
        return list.isProductChecked(productId)
    }
    
    /// Calculates completion statistics for products in a list
    /// - Parameters:
    ///   - products: Array of products to calculate statistics for
    ///   - list: The shopping list containing checked state
    /// - Returns: Tuple containing completed count and total count
    static func completionStats(for products: [Product], in list: ShoppingList) -> (completed: Int, total: Int) {
        let completedCount = products.filter { list.isProductChecked($0.id) }.count
        return (completedCount, products.count)
    }
}
