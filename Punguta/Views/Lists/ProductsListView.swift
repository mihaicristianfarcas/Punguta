//
//  ProductsListView.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 21.10.2025.
//

import SwiftUI

// MARK: - Products List View

/// Main view for browsing and managing all products
///
/// **Features**:
/// - Search functionality
/// - Category filtering
/// - Grouped display by category
/// - CRUD operations (Create, Read, Update, Delete)
/// - Swipe actions for quick edit/delete
/// - Coordination with ListViewModel for product-list relationships
struct ProductsListView: View {
    
    // MARK: Properties
    
    /// View model managing products
    @ObservedObject var productViewModel: ProductViewModel
    
    /// View model managing shopping lists (for cleanup on delete)
    @ObservedObject var listViewModel: ListViewModel
    
    /// Controls add product sheet visibility
    @State private var showingAddProduct = false
    
    /// Product currently being edited
    @State private var productToEdit: Product?
    
    /// Product marked for deletion
    @State private var productToDelete: Product?
    
    /// Controls delete confirmation alert
    @State private var showingDeleteConfirmation = false
    
    /// Current search query
    @State private var searchText = ""
    
    /// Currently selected category filter (nil = all categories)
    @State private var selectedCategory: UUID?
    
    /// All available categories
    private let categories = Category.defaultCategories
    
    // MARK: Computed Properties
    
    /// Products filtered by search and category
    /// Sorted alphabetically by name
    private var filteredProducts: [Product] {
        var filtered = productViewModel.products
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply category filter
        if let categoryId = selectedCategory {
            filtered = filtered.filter { $0.categoryId == categoryId }
        }
        
        return filtered.sorted { $0.name < $1.name }
    }
    
    /// Products grouped by category ID
    private var productsByCategory: [UUID: [Product]] {
        Dictionary(grouping: filteredProducts) { $0.categoryId }
    }
    
    /// Categories that have at least one product
    private var categoriesWithProducts: [Category] {
        categories.filter { productsByCategory[$0.id] != nil }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if filteredProducts.isEmpty {
                    if productViewModel.products.isEmpty {
                        EmptyStateView(
                            icon: "cart",
                            title: "No Products Yet",
                            message: "Create your first product to get started"
                        )
                    } else {
                        ProductsNoResultsView(searchText: searchText)
                    }
                } else {
                    List {
                        // Category filter pills
                        Section {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: AppTheme.Spacing.sm) {
                                    FilterPillView(
                                        title: "All",
                                        isSelected: selectedCategory == nil,
                                        action: { selectedCategory = nil }
                                    )
                                    
                                    ForEach(categories) { category in
                                        FilterPillView(
                                            title: category.name,
                                            icon: category.icon,
                                            color: category.visualColor,
                                            isSelected: selectedCategory == category.id,
                                            action: { 
                                                selectedCategory = selectedCategory == category.id ? nil : category.id
                                            }
                                        )
                                    }
                                }
                                .padding(.vertical, AppTheme.Spacing.sm)
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        
                        // Products grouped by category
                        ForEach(categoriesWithProducts) { category in
                            Section {
                                ForEach(productsByCategory[category.id] ?? []) { product in
                                    ProductRowView(
                                        product: product,
                                        category: category,
                                        onEdit: { productToEdit = product },
                                        onDelete: {
                                            productToDelete = product
                                            showingDeleteConfirmation = true
                                        }
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
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("All Products")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search products")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddProduct = true }) {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                }
            }
            .sheet(isPresented: $showingAddProduct) {
                AddEditProductView(
                    viewModel: productViewModel,
                    categories: categories
                )
            }
            .sheet(item: $productToEdit) { product in
                AddEditProductView(
                    viewModel: productViewModel,
                    categories: categories,
                    productToEdit: product
                )
            }
            .alert(
                "Delete Product",
                isPresented: $showingDeleteConfirmation,
                presenting: productToDelete
            ) { product in
                Button("Cancel", role: .cancel) {
                    productToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    withAnimation {
                        // Remove product from all lists first
                        listViewModel.removeProductFromAllLists(product.id)
                        // Then delete the product
                        productViewModel.deleteProduct(product)
                    }
                    productToDelete = nil
                }
            } message: { product in
                Text("Are you sure you want to delete '\(product.name)'? This will remove it from all shopping lists.")
            }
        }
    }
}

// MARK: - Product Row View
private struct ProductRowView: View {
    let product: Product
    let category: Category
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            ZStack {
                Circle()
                    .fill(category.visualColor.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: category.icon)
                    .foregroundStyle(category.visualColor)
                    .font(.system(size: 18))
            }
            
            // Product info
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.body)
                    .fontWeight(.medium)
                
                HStack {
                    Text(product.quantity.displayString)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if product.isChecked {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.caption)
                    }
                }
            }
            
            Spacer()
        }
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
            
            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
        .contextMenu {
            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }
            
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// MARK: - No Results View

/// Displays when search returns no results
private struct ProductsNoResultsView: View {
    let searchText: String
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: AppTheme.IconSize.huge))
                .foregroundStyle(AppTheme.Colors.secondaryText)
            
            VStack(spacing: AppTheme.Spacing.sm) {
                Text("No Results")
                    .font(.title2)
                    .fontWeight(AppTheme.FontWeight.bold)
                    .foregroundStyle(AppTheme.Colors.primaryText)
                
                Text("No products found for '\(searchText)'")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(AppTheme.Spacing.xl)
    }
}

// MARK: - Preview
#Preview {
    ProductsListView(productViewModel: ProductViewModel(), listViewModel: ListViewModel())
}
