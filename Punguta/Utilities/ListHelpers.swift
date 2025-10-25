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
        listViewModel.clearCheckedItems(in: listId)
    }
    
    /// Calculate completion statistics for a list
    /// - Parameters:
    ///   - products: All products in the list
    ///   - list: The shopping list to check against
    /// - Returns: Tuple with completed and total counts
    static func completionStats(for products: [Product], in list: ShoppingList) -> (completed: Int, total: Int) {
        let total = products.count
        let completed = products.filter { list.isProductChecked($0) }.count
        return (completed: completed, total: total)
    }
}
