//
//  StoreDetailView.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 21.10.2025.
//

import SwiftUI
import MapKit
import SwiftData

// MARK: - Store Detail View

/// Detailed view of a store with all its products organized by category
/// Features:
/// - Store header with icon, name, and type badge
/// - Products organized by store's category order
/// - Interactive product cards with checkboxes
/// - Empty states for missing data
/// - Color-coded UI based on store type
struct StoreDetailView: View {
    
    // MARK: Environment
    
    @Environment(\.modelContext) private var modelContext
    
    // MARK: Queries
    
    /// All categories from SwiftData
    @Query(sort: \Category.name) private var allCategories: [Category]
    
    /// All shopping lists from SwiftData
    @Query(sort: \ShoppingList.updatedAt, order: .reverse) private var allShoppingLists: [ShoppingList]
    
    // MARK: Properties
    
    /// The store being displayed
    let store: Store
    
    /// View model for store operations
    let storeViewModel: StoreViewModel
    
    /// View model for accessing products data
    @ObservedObject var productViewModel: ProductViewModel
    
    /// View model for accessing shopping lists data
    @ObservedObject var listViewModel: ListViewModel
    
    // MARK: Computed Properties
    
    /// Categories in the store's custom ordering
    private var orderedCategories: [Category] {
        store.categoryOrder.compactMap { categoryId in
            allCategories.first { $0.id == categoryId }
        }
    }
    
    /// All products across all lists that are available at this store
    private var allStoreProducts: [Product] {
        let allProducts = allShoppingLists.flatMap { $0.products }
        return allProducts.filter { product in
            if let categoryId = product.category?.id {
                return store.categoryOrder.contains(categoryId)
            }
            return false
        }
    }
    
    /// Number of checked/completed products at this store across all lists
    private var completedCount: Int {
        allShoppingLists.reduce(0) { total, list in
            let storeProducts = list.products.filter { product in
                if let categoryId = product.category?.id {
                    return store.categoryOrder.contains(categoryId)
                }
                return false
            }
            let checkedCount = storeProducts.filter { product in
                listViewModel.isProductChecked(product, in: list.id)
            }.count
            return total + checkedCount
        }
    }
    
    /// Completion percentage (0.0 to 1.0) for progress bar
    /// Returns 0 if list is empty to avoid division by zero
    private var progressPercentage: Double {
        guard !allStoreProducts.isEmpty else { return 0 }
        return Double(completedCount) / Double(allStoreProducts.count)
    }
    
    /// Shopping lists with products available at this store, organized by category
    /// Structure: [(list, [(category, [products])])]
    private var listsWithStoreProducts: [(list: ShoppingList, categorizedProducts: [(category: Category, products: [Product])])] {
        allShoppingLists.compactMap { list in
            // Get products from this list via junction model
            let listProducts = list.products
            
            // Filter to only products available at this store (matching store's categories)
            let storeProducts = listProducts.filter { product in
                if let categoryId = product.category?.id {
                    return store.categoryOrder.contains(categoryId)
                }
                return false
            }
            
            guard !storeProducts.isEmpty else { return nil }
            
            // Group products by category following store's category order
            let categorizedProducts = orderedCategories.compactMap { category -> (Category, [Product])? in
                let productsInCategory = storeProducts.filter { $0.category?.id == category.id }
                guard !productsInCategory.isEmpty else { return nil }
                return (category, productsInCategory.sorted { $0.name < $1.name })
            }
            
            guard !categorizedProducts.isEmpty else { return nil }
            
            return (list, categorizedProducts)
        }
    }
    
    // MARK: Body
    
    var body: some View {
        List {
            // MARK: Progress Header Card
            Section {
                ProgressHeaderCard(
                    totalItems: allStoreProducts.count,
                    completedItems: completedCount,
                    progressPercentage: progressPercentage
                )
            }
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            
            // MARK: Shopping Lists by Category
            if listsWithStoreProducts.isEmpty {
                Section {
                    EmptyListsState()
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                }
            } else {
                ForEach(listsWithStoreProducts, id: \.list.id) { listItem in
                    // Get all products for this list at this store
                    let allProducts = listItem.categorizedProducts.flatMap { $0.products }
                    
                    // List section header
                    Section {
                        EmptyView()
                    } header: {
                        ListSectionHeader(
                            list: listItem.list,
                            products: allProducts,
                            showUncheckAll: true,
                            onUncheckAll: { clearCheckedItems(for: listItem.list) }
                        )
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    
                    // Products list component (creates its own sections)
                    ProductsListComponent(
                        categories: orderedCategories,
                        products: allProducts,
                        categoryOrder: store.categoryOrder,
                        areProductsCheckable: true,
                        isProductChecked: { product in
                            listViewModel.isProductChecked(product, in: listItem.list.id)
                        },
                        onToggle: { product in
                            listViewModel.toggleProductChecked(product, in: listItem.list.id)
                        }
                    )
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .navigationTitle(store.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Helper Methods
    
    /// Clears all checked items from the specified list
    private func clearCheckedItems(for list: ShoppingList) {
        ListHelpers.clearCheckedItems(listId: list.id, in: listViewModel)
    }
}

// MARK: - Location Section

/// Displays store location information
/// Shows both human-readable address (if available) and precise coordinates
private struct LocationSection: View {
    let store: Store
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // Section header
            Text("Location")
                .font(.headline)
                .foregroundStyle(.primary)
                .padding(.horizontal, AppTheme.Spacing.md)
            
            VStack(spacing: AppTheme.Spacing.md) {
                // MARK: Address Card
                // Only shown if address is available
                if let address = store.location.address {
                    HStack(spacing: AppTheme.Spacing.md) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.red)
                        
                        Text(address)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                    }
                    .padding(AppTheme.Spacing.md)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md))
                }
                
                // MARK: Coordinates Card
                // Always shown, displays latitude and longitude
                HStack(spacing: AppTheme.Spacing.md) {
                    Image(systemName: "location.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.blue)
                    
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                        Text("Coordinates")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text("\(store.location.latitude, specifier: "%.4f"), \(store.location.longitude, specifier: "%.4f")")
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                    }
                    
                    Spacer()
                }
                .padding(AppTheme.Spacing.md)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md))
            }
            .padding(.horizontal, AppTheme.Spacing.md)
        }
    }
}

// MARK: - Empty Lists State

/// Empty state shown when store has no shopping lists with matching products
private struct EmptyListsState: View {
    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Text("No shopping lists")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text("Shopping lists with products available at this store will appear here")
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
    let modelContext = ModelContext(try! ModelContainer(for: Store.self, Product.self, Category.self, ShoppingList.self))
    let storeViewModel = StoreViewModel(modelContext: modelContext)
    let productViewModel = ProductViewModel(modelContext: modelContext)
    let listViewModel = ListViewModel(modelContext: modelContext)
    
    let store = storeViewModel.createStore(
        name: "Sample Store",
        type: .grocery,
        location: StoreLocation(
            coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            address: "123 Main St"
        ),
        categoryOrder: []
    )
    
    return NavigationStack {
        StoreDetailView(
            store: store,
            storeViewModel: storeViewModel,
            productViewModel: productViewModel,
            listViewModel: listViewModel
        )
    }
    .modelContainer(try! ModelContainer(for: Store.self, Product.self, Category.self, ShoppingList.self))
}
