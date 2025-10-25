//
//  ProductsListComponent.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 25.10.2025.
//

import SwiftUI
import SwiftData

// MARK: - Products List Component

/// Reusable component for displaying products grouped by category
/// Can be used with or without checkbox functionality
/// Matches ProductsListView styling exactly
struct ProductsListComponent: View {
    
    // MARK: Properties
    
    /// All categories available in the app
    let categories: [Category]
    
    /// Products to display
    let products: [Product]
    
    /// Optional category order (nil = alphabetical, used for stores)
    let categoryOrder: [UUID]?
    
    /// Whether products should have checkboxes
    let areProductsCheckable: Bool
    
    // MARK: Checkable-only Properties
    
    /// Callback to check if a product is checked (only used if areProductsCheckable = true)
    var isProductChecked: ((Product) -> Bool)?
    
    /// Callback when checkbox is toggled (only used if areProductsCheckable = true)
    var onToggle: ((Product) -> Void)?
    
    // MARK: Action Properties
    
    /// Optional edit action
    var onEdit: ((Product) -> Void)? = nil
    
    /// Optional delete action
    var onDelete: ((Product) -> Void)? = nil
    
    // MARK: Computed Properties
    
    /// Products sorted by checked state (if checkable) and name
    private var sortedProducts: [Product] {
        products.sorted { p1, p2 in
            if areProductsCheckable, let isProductChecked = isProductChecked {
                let p1Checked = isProductChecked(p1)
                let p2Checked = isProductChecked(p2)
                
                // Unchecked items first
                if p1Checked != p2Checked {
                    return !p1Checked
                }
            }
            
            // Then alphabetically
            return p1.name < p2.name
        }
    }
    
    /// Products grouped by category
    private var productsByCategory: [Category: [Product]] {
        Dictionary(grouping: sortedProducts) { product in
            product.category ?? Category(name: "Uncategorized", keywords: [], defaultUnit: nil)
        }
    }
    
    /// Categories ordered according to categoryOrder or alphabetically
    private var orderedCategories: [Category] {
        if let categoryOrder = categoryOrder {
            // Use custom order (for stores)
            return categoryOrder.compactMap { categoryId in
                categories.first { $0.id == categoryId }
            }.filter { category in
                // Only include categories that have products
                productsByCategory[category] != nil
            }
        } else {
            // Use alphabetical order
            return Array(productsByCategory.keys).sorted { $0.name < $1.name }
        }
    }
    
    // MARK: Body
    
    var body: some View {
        // Products grouped by category (matching ProductsListView structure)
        ForEach(orderedCategories) { category in
            Section {
                ForEach(productsByCategory[category] ?? []) { product in
                    ProductRowViewComponent(
                        product: product,
                        category: category,
                        isCheckable: areProductsCheckable,
                        isChecked: areProductsCheckable ? (isProductChecked?(product) ?? false) : false,
                        onToggle: areProductsCheckable ? { onToggle?(product) } : nil,
                        onEdit: onEdit != nil ? { onEdit?(product) } : nil,
                        onDelete: onDelete != nil ? { onDelete?(product) } : nil
                    )
                }
            } header: {
                HStack {
                    Image(systemName: category.icon)
                        .foregroundStyle(category.visualColor)
                    Text(category.name)
                }
                .font(.headline)
            }
        }
    }
}

// MARK: - Product Row View Component

/// Product row view - matches ProductRowView styling with optional checkbox
private struct ProductRowViewComponent: View {
    let product: Product
    let category: Category
    let isCheckable: Bool
    let isChecked: Bool
    let onToggle: (() -> Void)?
    let onEdit: (() -> Void)?
    let onDelete: (() -> Void)?
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Optional checkbox
            if isCheckable, let onToggle = onToggle {
                Button(action: onToggle) {
                    Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(isChecked ? .green : .secondary)
                }
                .buttonStyle(.plain)
            }
            
            // Product info (identical to ProductRowView)
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(product.name)
                    .font(.body)
                    .fontWeight(AppTheme.FontWeight.semibold)
                    .foregroundStyle(isCheckable && isChecked ? .secondary : .primary)
                    .strikethrough(isCheckable && isChecked, color: .secondary)
                
                Text(product.quantity.displayString)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .contentShape(Rectangle())
        .modifier(ProductSwipeActionsModifier(
            onEdit: onEdit,
            onDelete: onDelete
        ))
    }
}

// MARK: - Product Swipe Actions Modifier

/// Conditionally applies swipe actions when callbacks are provided
private struct ProductSwipeActionsModifier: ViewModifier {
    let onEdit: (() -> Void)?
    let onDelete: (() -> Void)?
    
    func body(content: Content) -> some View {
        if let onEdit = onEdit, let onDelete = onDelete {
            content
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(action: onDelete) {
                        Label("Delete", systemImage: "trash")
                    }
                    .tint(.red)
                    
                    Button(action: onEdit) {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.orange)
                }
        } else {
            content
        }
    }
}

// MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Category.self, Product.self, ShoppingList.self,
        configurations: config
    )
    let context = ModelContext(container)
    
    // Create sample data
    let produce = Category(name: "Produce", keywords: ["apple"], defaultUnit: "kg")
    let dairy = Category(name: "Dairy", keywords: ["milk"], defaultUnit: "L")
    context.insert(produce)
    context.insert(dairy)
    
    let apples = Product(name: "Apples", category: produce, quantity: ProductQuantity(amount: 2, unit: "kg"))
    let milk = Product(name: "Milk", category: dairy, quantity: ProductQuantity(amount: 1, unit: "L"))
    let bananas = Product(name: "Bananas", category: produce, quantity: ProductQuantity(amount: 3, unit: "kg"))
    context.insert(apples)
    context.insert(milk)
    context.insert(bananas)
    
    try? context.save()
    
    @State var checkedProducts: Set<UUID> = [apples.id]
    
    return NavigationStack {
        List {
            ProductsListComponent(
                categories: [produce, dairy],
                products: [apples, milk, bananas],
                categoryOrder: nil,
                areProductsCheckable: true,
                isProductChecked: { product in
                    checkedProducts.contains(product.id)
                },
                onToggle: { product in
                    if checkedProducts.contains(product.id) {
                        checkedProducts.remove(product.id)
                    } else {
                        checkedProducts.insert(product.id)
                    }
                },
                onEdit: { _ in },
                onDelete: { _ in }
            )
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Preview")
    }
    .modelContainer(container)
}
