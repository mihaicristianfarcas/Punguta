//
//  ListDetailView.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 21.10.2025.
//

import SwiftUI

// MARK: - List Detail View

/// Displays detailed view of a shopping list with all its products
/// Features:
/// - Visual progress tracking (completed vs total items)
/// - Interactive product cards with checkbox, edit, and delete actions
/// - Add new products or select from existing products
/// - Real-time progress updates
/// - Search and filter within product picker
struct ListDetailView: View {
    
    // MARK: Properties
    
    /// The shopping list being displayed (mutable for in-place updates)
    @State var list: ShoppingList
    
    /// View model managing products
    @ObservedObject var productViewModel: ProductViewModel
    
    /// View model managing lists
    @ObservedObject var listViewModel: ListViewModel
    
    // MARK: Sheet State
    
    /// Controls display of the product picker sheet (select existing products)
    @State private var showingProductPicker = false
    
    /// Controls display of the add new product sheet
    @State private var showingAddProduct = false
    
    /// Product being edited (triggers edit sheet when set)
    @State private var productToEdit: Product?
    
    /// Product pending deletion (used in confirmation alert)
    @State private var productToDelete: Product?
    
    /// Controls display of delete confirmation alert
    @State private var showingDeleteConfirmation = false
    
    // MARK: Computed Properties
    
    /// Resolves product IDs to actual Product objects
    /// Filters out any invalid IDs (products that may have been deleted)
    private var products: [Product] {
        list.productIds.compactMap { id in
            productViewModel.products.first { $0.id == id }
        }
    }
    
    /// Number of checked/completed products in this list
    private var completedCount: Int {
        products.filter { $0.isChecked }.count
    }
    
    /// Completion percentage (0.0 to 1.0) for progress bar
    /// Returns 0 if list is empty to avoid division by zero
    private var progressPercentage: Double {
        guard !products.isEmpty else { return 0 }
        return Double(completedCount) / Double(products.count)
    }
    
    // MARK: Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.xl) {
                // MARK: Header Card Section
                // Shows list info, stats, and progress bar
                ListHeaderCard(
                    list: list,
                    products: products,
                    completedCount: completedCount,
                    progressPercentage: progressPercentage
                )
                
                // MARK: Products Section
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    // Section header with Add menu
                    HStack {
                        Text("Products")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        // Menu with two options: create new or add existing
                        Menu {
                            Button(action: { showingAddProduct = true }) {
                                Label("Create New Product", systemImage: "plus.circle")
                            }
                            
                            Button(action: { showingProductPicker = true }) {
                                Label("Add Existing Product", systemImage: "list.bullet")
                            }
                        } label: {
                            HStack(spacing: AppTheme.Spacing.xs) {
                                Image(systemName: "plus.circle.fill")
                                Text("Add")
                                    .fontWeight(.medium)
                            }
                            .font(.subheadline)
                            .foregroundStyle(.blue)
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.md)
                    
                    // Product list or empty state
                    if products.isEmpty {
                        EmptyProductsState()
                    } else {
                        VStack(spacing: AppTheme.Spacing.md) {
                            ForEach(products) { product in
                                InteractiveProductCard(
                                    product: product,
                                    onToggle: { toggleProduct(product) },
                                    onEdit: { productToEdit = product },
                                    onDelete: {
                                        productToDelete = product
                                        showingDeleteConfirmation = true
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, AppTheme.Spacing.md)
                    }
                }
            }
            .padding(.vertical, AppTheme.Spacing.lg)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(list.name)
        .navigationBarTitleDisplayMode(.inline)
        // MARK: Sheets
        // Sheet for creating a new product
        .sheet(isPresented: $showingAddProduct) {
            AddEditProductView(
                viewModel: productViewModel,
                categories: Category.defaultCategories
            )
        }
        // Sheet for editing an existing product
        .sheet(item: $productToEdit) { product in
            AddEditProductView(
                viewModel: productViewModel,
                categories: Category.defaultCategories,
                productToEdit: product
            )
        }
        // Sheet for selecting existing products to add to this list
        .sheet(isPresented: $showingProductPicker) {
            ProductPickerView(
                selectedProductIds: Binding(
                    get: { list.productIds },
                    set: { newIds in
                        list.productIds = newIds
                        list.updatedAt = Date()
                        listViewModel.updateList(list)
                    }
                ),
                availableProducts: productViewModel.products
            )
        }
        // MARK: Alert
        // Confirmation alert before removing a product from the list
        .alert(
            "Remove Product",
            isPresented: $showingDeleteConfirmation,
            presenting: productToDelete
        ) { product in
            Button("Cancel", role: .cancel) {
                productToDelete = nil
            }
            Button("Remove", role: .destructive) {
                removeProduct(product)
                productToDelete = nil
            }
        } message: { product in
            Text("Remove '\(product.name)' from this list?")
        }
    }
    
    // MARK: - Helper Methods
    
    /// Toggles the checked state of a product
    /// Delegates to ProductViewModel which handles persistence
    private func toggleProduct(_ product: Product) {
        productViewModel.toggleProductChecked(product)
    }
    
    /// Removes a product from this list (but doesn't delete the product globally)
    /// Updates the list's product IDs and timestamp
    private func removeProduct(_ product: Product) {
        list.removeProduct(product.id)
        listViewModel.updateList(list)
    }
}

// MARK: - Interactive Product Card

/// Product card with multiple interactive elements
/// - Checkbox button to toggle completion state
/// - Tappable product info area to edit
/// - Explicit edit and delete buttons
/// - Strikethrough styling for completed items
private struct InteractiveProductCard: View {
    let product: Product
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // MARK: Checkbox Button
            // Circular button that toggles product completion
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .fill(product.isChecked ? Color.green : Color.gray.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    if product.isChecked {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .buttonStyle(.plain)
            
            // MARK: Product Info (Tappable to Edit)
            Button(action: onEdit) {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(product.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .strikethrough(product.isChecked, color: .secondary)
                    
                    Text(product.quantity.displayString)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            // MARK: Action Buttons
            // Explicit edit and delete buttons
            HStack(spacing: AppTheme.Spacing.md) {
                Button(action: onEdit) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
                
                Button(action: onDelete) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md))
        .shadow(
            color: AppTheme.Shadow.sm.color,
            radius: AppTheme.Shadow.sm.radius,
            x: AppTheme.Shadow.sm.x,
            y: AppTheme.Shadow.sm.y
        )
    }
}

// MARK: - Product Picker View

/// Modal sheet for selecting existing products to add to the list
/// Features:
/// - Searchable list of all available products
/// - Multi-select with checkmark indicators
/// - Real-time filtering as user types
private struct ProductPickerView: View {
    @Environment(\.dismiss) private var dismiss
    
    /// Binding to the list's product IDs (updated when selections change)
    @Binding var selectedProductIds: [UUID]
    
    /// All products available for selection
    let availableProducts: [Product]
    
    /// Search query text
    @State private var searchText = ""
    
    /// Filters products by name based on search text
    private var filteredProducts: [Product] {
        if searchText.isEmpty {
            return availableProducts
        }
        return availableProducts.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredProducts) { product in
                    Button(action: { toggleProduct(product) }) {
                        HStack(spacing: AppTheme.Spacing.md) {
                            // Checkmark indicator
                            Image(systemName: selectedProductIds.contains(product.id) ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(selectedProductIds.contains(product.id) ? .blue : .secondary)
                                .font(.title3)
                            
                            // Product info
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                                Text(product.name)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                
                                Text(product.quantity.displayString)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search products")
            .navigationTitle("Add Products")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    /// Toggles product selection on/off
    /// Adds or removes product ID from the selected list
    private func toggleProduct(_ product: Product) {
        if let index = selectedProductIds.firstIndex(of: product.id) {
            selectedProductIds.remove(at: index)
        } else {
            selectedProductIds.append(product.id)
        }
    }
}

// MARK: - Supporting Views

// MARK: List Header Card

/// Header card displaying list information, statistics, and progress
/// Shows:
/// - List name with color-coded icon
/// - Item count and completion stats
/// - Animated progress bar
/// - Last updated timestamp
private struct ListHeaderCard: View {
    let list: ShoppingList
    let products: [Product]
    let completedCount: Int
    let progressPercentage: Double
    
    /// Deterministic color based on list name hash
    /// Ensures consistent color per list across app sessions
    private var listColor: Color {
        let colors: [Color] = [.blue, .purple, .pink, .indigo, .teal, .cyan]
        let index = abs(list.name.hashValue) % colors.count
        return colors[index]
    }
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // MARK: List Name Header
            HStack {
                // Color-coded icon
                ZStack {
                    Circle()
                        .fill(listColor.gradient)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "list.bullet.clipboard.fill")
                        .font(.system(size: 30, weight: .medium))
                        .foregroundStyle(.white)
                }
                
                Text(list.name)
                    .font(.title)
                    .bold()
                    .lineLimit(1)
                    .padding()
            }
            
            // MARK: Statistics and Progress
            VStack(spacing: AppTheme.Spacing.md) {
                // Stat cards showing totals
                HStack(spacing: AppTheme.Spacing.xl) {
                    StatCard(
                        icon: "cart.fill",
                        value: "\(products.count)",
                        label: products.count == 1 ? "Item" : "Items",
                        color: .blue
                    )
                    
                    StatCard(
                        icon: "checkmark.circle.fill",
                        value: "\(completedCount)",
                        label: "Completed",
                        color: .green
                    )
                }
                
                // MARK: Progress Bar
                // Only shown when list has products
                if !products.isEmpty {
                    VStack(spacing: AppTheme.Spacing.sm) {
                        HStack {
                            Text("Progress")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            Text("\(Int(progressPercentage * 100))%")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(listColor)
                        }
                        
                        // Animated progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background track
                                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 12)
                                
                                // Filled progress
                                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm)
                                    .fill(listColor.gradient)
                                    .frame(width: geometry.size.width * progressPercentage, height: 12)
                                    .animation(.spring(response: 0.3), value: progressPercentage)
                            }
                        }
                        .frame(height: 12)
                    }
                    .padding(.horizontal, AppTheme.Spacing.xs)
                }
                
                // MARK: Last Updated Timestamp
                Text("Updated \(list.updatedAt, style: .relative) ago")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.xl)
        .padding(.horizontal, AppTheme.Spacing.lg)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg))
        .shadow(
            color: AppTheme.Shadow.md.color,
            radius: AppTheme.Shadow.md.radius,
            x: AppTheme.Shadow.md.x,
            y: AppTheme.Shadow.md.y
        )
        .padding(.horizontal, AppTheme.Spacing.md)
    }
}

// MARK: Stat Card

/// Reusable stat card component
/// Displays an icon, numeric value, and label in a colored card
/// Used for showing metrics like item count, completion count, etc.
private struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.md)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md))
    }
}

// MARK: Empty Products State

/// Empty state shown when list has no products
/// Displays helpful message with icon and instructions
private struct EmptyProductsState: View {
    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "cart.badge.plus")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)
            
            VStack(spacing: AppTheme.Spacing.sm) {
                Text("No products yet")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text("Tap 'Add' to add products to this list")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md))
        .padding(.horizontal, AppTheme.Spacing.md)
    }
}

// MARK: - Preview
#Preview {
    let productViewModel = ProductViewModel()
    let listViewModel = ListViewModel()
    listViewModel.initializeSampleLists(with: productViewModel.products)
    let list = listViewModel.shoppingLists.first!
    return ListDetailView(
        list: list,
        productViewModel: productViewModel,
        listViewModel: listViewModel
    )
}
