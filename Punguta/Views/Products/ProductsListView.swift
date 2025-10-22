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
                
                List {
                    CategoryFilterSection(categories: categories, selectedCategory: $selectedCategory)
                    
                    // Products or empty states
                    if filteredProducts.isEmpty {
                        if productViewModel.products.isEmpty {
                            Section {
                                EmptyStateView(
                                    icon: "cart",
                                    title: "No Products Yet",
                                    message: "Create your first product to get started"
                                )
                                .frame(maxWidth: .infinity)
                                .listRowInsets(EdgeInsets())
                            }
                        } else {
                            Section {
                                ProductsNoResultsView()
                                    .frame(maxWidth: .infinity)
                                    .listRowInsets(EdgeInsets())
                            }
                        }
                    } else {
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
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("All Products")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search products")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddProduct = true
                    } label: {
                        Image(systemName: "plus")
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
        HStack(spacing: AppTheme.Spacing.md) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(product.name)
                    .font(.body)
                    .fontWeight(AppTheme.FontWeight.semibold)
                    .foregroundStyle(.primary)
                
                Text(product.quantity.displayString)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .contentShape(Rectangle())
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
    }
}

// MARK: - No Results View

/// Displays when search returns no results
private struct ProductsNoResultsView: View {
    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Text("No Results")
                .font(.subheadline)
                .fontWeight(AppTheme.FontWeight.semibold)
                .foregroundStyle(.primary)
            
            Text("No products found")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.xl)
    }
}

// MARK: - Category Filter Section
private struct CategoryFilterSection: View {
    let categories: [Category]
    @Binding var selectedCategory: UUID?

    var body: some View {
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
                                selectedCategory = (selectedCategory == category.id) ? nil : category.id
                            }
                        )
                    }
                }
                .padding(AppTheme.Spacing.sm)
            }
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}

// MARK: - Preview
#Preview {
    ProductsListView(productViewModel: ProductViewModel(), listViewModel: ListViewModel())
}
