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
        list.checkedProductIds.count
    }
    
    /// Completion percentage (0.0 to 1.0) for progress bar
    /// Returns 0 if list is empty to avoid division by zero
    private var progressPercentage: Double {
        guard !products.isEmpty else { return 0 }
        return Double(completedCount) / Double(products.count)
    }
    
    // MARK: Body
    
    var body: some View {
        List {
            // MARK: Header Card Section
            Section {
                ListHeaderCard(
                    list: list,
                    products: products,
                    completedCount: completedCount,
                    progressPercentage: progressPercentage
                )
            }
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            
            // MARK: Products Section
            Section {
                if products.isEmpty {
                    EmptyProductsState()
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                } else {
                    ForEach(products) { product in
                        InteractiveProductCard(
                            product: product,
                            isChecked: list.isProductChecked(product.id),
                            onToggle: { toggleProduct(product) },
                            onEdit: { productToEdit = product },
                            onDelete: {
                                productToDelete = product
                                showingDeleteConfirmation = true
                            }
                        )
                        .listRowInsets(EdgeInsets(top: AppTheme.Spacing.xs, leading: AppTheme.Spacing.md, bottom: AppTheme.Spacing.xs, trailing: AppTheme.Spacing.md))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }
            } header: {
                HStack {
                    Text("Products")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Menu {
                        Button(action: { showingAddProduct = true }) {
                            Label("Create New", systemImage: "plus")
                        }
                        
                        Button(action: { showingProductPicker = true }) {
                            Label("Add Existing", systemImage: "list.bullet")
                        }
                    } label: {
                        Text("Add")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.blue)
                    }
                }
                .textCase(nil)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .navigationTitle(list.name)
        .navigationBarTitleDisplayMode(.inline)
        // MARK: Sheets
        // Sheet for creating a new product
        .sheet(isPresented: $showingAddProduct) {
            AddEditProductView(
                viewModel: productViewModel,
                categories: Category.defaultCategories,
                onProductCreated: { productId in
                    // Add the newly created product to this list
                    list.addProduct(productId)
                    listViewModel.updateList(list)
                }
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
                availableProducts: productViewModel.products,
                productViewModel: productViewModel
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
    
    /// Toggles the checked state of a product in this list
    private func toggleProduct(_ product: Product) {
        list.toggleProductChecked(product.id)
        listViewModel.updateList(list)
    }
    
    /// Removes a product from this list (but doesn't delete the product globally)
    /// Updates the list's product IDs and timestamp
    private func removeProduct(_ product: Product) {
        list.removeProduct(product.id)
        listViewModel.updateList(list)
    }
}

// MARK: - Interactive Product Card

/// Minimal product card with checkbox and swipe actions
private struct InteractiveProductCard: View {
    let product: Product
    let isChecked: Bool
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Checkbox
            Button(action: onToggle) {
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isChecked ? .green : .secondary)
            }
            .buttonStyle(.plain)
            
            // Product Info
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(product.name)
                    .font(.body)
                    .fontWeight(AppTheme.FontWeight.semibold)
                    .foregroundStyle(isChecked ? .secondary : .primary)
                    .strikethrough(isChecked, color: .secondary)
                
                Text(product.quantity.displayString)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(AppTheme.Spacing.md)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md))
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(action: onDelete) {
                Label("Remove", systemImage: "trash")
            }
            .tint(.red)
            
            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.orange)
        }
    }
}

// MARK: - Product Picker View

/// Modal sheet for selecting existing products to add to the list
private struct ProductPickerView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var selectedProductIds: [UUID]
    let availableProducts: [Product]
    let productViewModel: ProductViewModel
    
    @State private var searchText = ""
    @State private var showingAddProduct = false
    
    private var filteredProducts: [Product] {
        if searchText.isEmpty {
            return availableProducts.sorted { $0.name < $1.name }
        }
        return availableProducts
            .filter { $0.name.localizedCaseInsensitiveContains(searchText) }
            .sorted { $0.name < $1.name }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if filteredProducts.isEmpty {
                    Section {
                        Text("No products found")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, AppTheme.Spacing.lg)
                    }
                } else {
                    ForEach(filteredProducts) { product in
                        Button(action: { toggleProduct(product) }) {
                            HStack(spacing: AppTheme.Spacing.md) {
                                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                                    Text(product.name)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                    
                                    Text(product.quantity.displayString)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                if selectedProductIds.contains(product.id) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                        .font(.body.weight(.semibold))
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .searchable(text: $searchText, prompt: "Search products")
            .navigationTitle("Add Products")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Button {
                        showingAddProduct = true
                    } label: {
                        HStack(spacing: AppTheme.Spacing.xs) {
                            Image(systemName: "plus.circle.fill")
                            Text("Create New")
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showingAddProduct) {
                AddEditProductView(
                    viewModel: productViewModel,
                    categories: Category.defaultCategories,
                    onProductCreated: { productId in
                        // Automatically select the newly created product
                        selectedProductIds.append(productId)
                    }
                )
            }
        }
    }
    
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

/// Minimal header card displaying list progress
private struct ListHeaderCard: View {
    let list: ShoppingList
    let products: [Product]
    let completedCount: Int
    let progressPercentage: Double
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // Statistics
            HStack(spacing: AppTheme.Spacing.xl) {
                VStack(spacing: AppTheme.Spacing.xs) {
                    Text("\(products.count)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    Text(products.count == 1 ? "Item" : "Items")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(height: 40)
                
                VStack(spacing: AppTheme.Spacing.xs) {
                    Text("\(completedCount)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.green)
                    
                    Text("Completed")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            
            // Progress Bar
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
                            .foregroundStyle(.primary)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm)
                                .fill(Color.green)
                                .frame(width: geometry.size.width * progressPercentage, height: 8)
                                .animation(.spring(response: 0.3), value: progressPercentage)
                        }
                    }
                    .frame(height: 8)
                }
            }
            
            Text("Updated \(list.updatedAt, style: .relative) ago")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.Spacing.lg)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md))
        .padding(.horizontal, AppTheme.Spacing.md)
    }
}

// MARK: Empty Products State

/// Empty state shown when list has no products
private struct EmptyProductsState: View {
    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Text("No products yet")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text("Tap 'Add' to add products to this list")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.xl)
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
