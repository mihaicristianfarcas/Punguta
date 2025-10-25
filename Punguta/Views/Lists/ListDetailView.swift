//
//  ListDetailView.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 21.10.2025.
//

import SwiftUI
import SwiftData

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
    
    /// The shopping list being displayed
    @Bindable var list: ShoppingList
    
    /// View model managing products
    @ObservedObject var productViewModel: ProductViewModel
    
    /// View model managing lists
    @ObservedObject var listViewModel: ListViewModel
    
    /// All categories from SwiftData
    @Query private var categories: [Category]
    
    /// All products from SwiftData
    @Query(sort: \Product.name) private var allProducts: [Product]
    
    // MARK: Sheet State
    
    /// Controls display of the product picker sheet (select existing products)
    @State private var showingProductPicker = false
    
    /// Controls display of the add new product sheet
    @State private var showingAddProduct = false
    
    /// Product being edited (triggers edit sheet when set)
    @State private var productToEdit: Product?
    
    /// Item pending deletion (used in confirmation alert)
    @State private var itemToDelete: ShoppingListItem?
    
    /// Controls display of delete confirmation alert
    @State private var showingDeleteConfirmation = false
    
    // MARK: Computed Properties
    
    /// Products in this list
    private var products: [Product] {
        list.products
    }
    
    /// Number of checked/completed products in this list
    private var completedCount: Int {
        list.checkedProducts.count
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
            if products.isEmpty {
                Section {
                    EmptyProductsState()
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                } header: {
                    HStack {
                        Text("Products")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        // Add Product Menu
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
                        .textCase(nil)
                    }
                }
            } else {
                // Header section with buttons
                Section {
                    EmptyView()
                } header: {
                    HStack {
                        Text("Products")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        HStack(spacing: AppTheme.Spacing.lg) {
                            // Clear Checked Items Button
                            if completedCount > 0 {
                                Button(action: clearCheckedItems) {
                                    Text("Uncheck All")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.red)
                                }
                            }
                            
                            // Add Product Menu
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
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                
                // Products list component (creates its own sections)
                ProductsListComponent(
                    categories: categories,
                    products: products,
                    categoryOrder: nil,
                    areProductsCheckable: true,
                    isProductChecked: { product in
                        list.items?.first(where: { $0.product?.id == product.id })?.isChecked ?? false
                    },
                    onToggle: { product in
                        listViewModel.toggleProductChecked(product, in: list)
                    },
                    onEdit: { product in
                        productToEdit = product
                    },
                    onDelete: { product in
                        if let item = list.items?.first(where: { $0.product?.id == product.id }) {
                            itemToDelete = item
                            showingDeleteConfirmation = true
                        }
                    }
                )
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .navigationTitle(list.name)
        .navigationBarTitleDisplayMode(.inline)
        // MARK: Sheets
        // Sheet for creating a new product
        .sheet(isPresented: $showingAddProduct) {
            AddEditProductView(
                productViewModel: productViewModel,
                onProductCreated: { product in
                    // Add the newly created product to this list
                    listViewModel.addProduct(product, to: list)
                }
            )
        }
        // Sheet for editing an existing product
        .sheet(item: $productToEdit) { product in
            AddEditProductView(
                productViewModel: productViewModel,
                productToEdit: product
            )
        }
        // Sheet for selecting existing products to add to this list
        .sheet(isPresented: $showingProductPicker) {
            ProductPickerView(
                list: list,
                availableProducts: allProducts,
                productViewModel: productViewModel,
                listViewModel: listViewModel,
                categories: categories
            )
        }
        // MARK: Alert
        // Confirmation alert before removing a product from the list
        .alert(
            "Remove Product",
            isPresented: $showingDeleteConfirmation,
            presenting: itemToDelete
        ) { item in
            Button("Cancel", role: .cancel) {
                itemToDelete = nil
            }
            Button("Remove", role: .destructive) {
                if let item = itemToDelete {
                    listViewModel.removeItem(item, from: list)
                }
                itemToDelete = nil
            }
        } message: { item in
            if let productName = item.product?.name {
                Text("Remove '\(productName)' from this list?")
            }
        }
    }
        
    // MARK: - Helper Methods
    
    /// Clears all checked items from the list
    /// Unmarks all checked products so the list can be reused
    private func clearCheckedItems() {
        guard let items = list.items else { return }
        for item in items where item.isChecked {
            item.isChecked = false
        }
        listViewModel.updateList(list)
    }
}

// MARK: - Product Picker View

/// Modal sheet for selecting existing products to add to the list
private struct ProductPickerView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var list: ShoppingList
    let availableProducts: [Product]
    let productViewModel: ProductViewModel
    let listViewModel: ListViewModel
    let categories: [Category]
    
    @State private var searchText = ""
    @State private var showingAddProduct = false
    
    private var filteredProducts: [Product] {
        if searchText.isEmpty {
            return availableProducts
        }
        return availableProducts
            .filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    private var selectedProductIds: Set<UUID> {
        Set(list.products.map { $0.id })
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
                    productViewModel: productViewModel,
                    onProductCreated: { product in
                        // Automatically add the newly created product
                        listViewModel.addProduct(product, to: list)
                    }
                )
            }
        }
    }
    
    private func toggleProduct(_ product: Product) {
        if selectedProductIds.contains(product.id) {
            listViewModel.removeProduct(product, from: list)
        } else {
            listViewModel.addProduct(product, to: list)
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
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Category.self, Product.self, ShoppingList.self, ShoppingListItem.self, Store.self,
        configurations: config
    )
    let context = ModelContext(container)
    
    // Create sample data
    let category = Category(name: "Produce", keywords: ["apple"], defaultUnit: "kg")
    context.insert(category)
    
    let product = Product(name: "Apples", category: category, quantity: ProductQuantity(amount: 1, unit: "kg"))
    context.insert(product)
    
    let list = ShoppingList(name: "Weekly Groceries")
    context.insert(list)
    list.addProduct(product)
    
    try? context.save()
    
    return NavigationStack {
        ListDetailView(
            list: list,
            productViewModel: ProductViewModel(modelContext: context),
            listViewModel: ListViewModel(modelContext: context)
        )
    }
    .modelContainer(container)
}
