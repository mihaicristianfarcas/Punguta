//
//  ListSectionHeader.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 23.10.2025.
//

import SwiftUI

// MARK: - List Section Header

/// Reusable section header for shopping lists showing name, progress, and optional actions
/// Used in both ListDetailView and StoreDetailView for consistent UI
struct ListSectionHeader: View {
    
    // MARK: Properties
    
    let listName: String
    let completedCount: Int
    let totalCount: Int
    var showUncheckAll: Bool = true
    var onUncheckAll: (() -> Void)? = nil
    
    // MARK: Computed Properties
    
    private var progressText: String {
        "\(completedCount)/\(totalCount)"
    }
    
    private var progressColor: Color {
        completedCount == totalCount && totalCount > 0 ? .green : .secondary
    }
    
    // MARK: Body
    
    var body: some View {
        HStack {
            Text(listName)
                .font(.headline)
                .foregroundStyle(.primary)
            
            Spacer()
            
            HStack(spacing: AppTheme.Spacing.md) {
                // Uncheck All Button (only shown if enabled and there are checked items)
                if showUncheckAll, completedCount > 0, let onUncheckAll = onUncheckAll {
                    Button(action: onUncheckAll) {
                        Text("Uncheck All")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.red)
                    }
                }
                
                // Progress indicator
                Text(progressText)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(progressColor)
            }
        }
        .textCase(nil)
    }
}

// MARK: - Convenience Initializers

extension ListSectionHeader {
    
    /// Initializer with automatic progress calculation from products and list
    init(
        list: ShoppingList,
        products: [Product],
        showUncheckAll: Bool = true,
        onUncheckAll: (() -> Void)? = nil
    ) {
        let stats = ListHelpers.completionStats(for: products, in: list)
        self.listName = list.name
        self.completedCount = stats.completed
        self.totalCount = stats.total
        self.showUncheckAll = showUncheckAll
        self.onUncheckAll = onUncheckAll
    }
}

// MARK: - Preview

#Preview("With Uncheck Button") {
    List {
        Section {
            Text("Product 1")
            Text("Product 2")
            Text("Product 3")
        } header: {
            ListSectionHeader(
                listName: "Weekly Shopping",
                completedCount: 2,
                totalCount: 5,
                showUncheckAll: true,
                onUncheckAll: { print("Uncheck all tapped") }
            )
        }
    }
}

#Preview("Without Uncheck Button") {
    List {
        Section {
            Text("Product 1")
            Text("Product 2")
        } header: {
            ListSectionHeader(
                listName: "Weekly Shopping",
                completedCount: 0,
                totalCount: 5,
                showUncheckAll: true,
                onUncheckAll: { print("Uncheck all tapped") }
            )
        }
    }
}

#Preview("All Complete") {
    List {
        Section {
            Text("Product 1")
            Text("Product 2")
        } header: {
            ListSectionHeader(
                listName: "Weekly Shopping",
                completedCount: 5,
                totalCount: 5,
                showUncheckAll: true,
                onUncheckAll: { print("Uncheck all tapped") }
            )
        }
    }
}
