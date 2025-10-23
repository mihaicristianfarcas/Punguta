//
//  StoreDetailView.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 21.10.2025.
//

import SwiftUI
import MapKit

// MARK: - Store Detail View

/// Detailed view of a store with all its products organized by category
/// Features:
/// - Store header with icon, name, and type badge
/// - Products organized by store's category order
/// - Interactive product cards with checkboxes
/// - Empty states for missing data
/// - Color-coded UI based on store type
struct StoreDetailView: View {
    
    // MARK: Properties
    
    /// The store being displayed
    let store: Store
    
    /// View model for accessing categories data
    let viewModel: StoreViewModel
    
    /// View model for accessing products data
    @ObservedObject var productViewModel: ProductViewModel
    
    /// View model for accessing shopping lists data
    @ObservedObject var listViewModel: ListViewModel
    
    // MARK: Computed Properties
    
    /// Categories in the store's custom ordering
    private var orderedCategories: [Category] {
        store.categoryOrder.compactMap { categoryId in
            viewModel.categories.first { $0.id == categoryId }
        }
    }
    
    /// Shopping lists with products available at this store, organized by category
    /// Structure: [(list, [(category, [products])])]
    private var listsWithStoreProducts: [(list: ShoppingList, categorizedProducts: [(category: Category, products: [Product])])] {
        listViewModel.shoppingLists.compactMap { list in
            // Get products from this list
            let listProducts = list.productIds.compactMap { productId in
                productViewModel.products.first { $0.id == productId }
            }
            
            // Filter to only products available at this store (matching store's categories)
            let storeProducts = listProducts.filter { product in
                store.categoryOrder.contains(product.categoryId)
            }
            
            guard !storeProducts.isEmpty else { return nil }
            
            // Group products by category following store's category order
            let categorizedProducts = orderedCategories.compactMap { category -> (Category, [Product])? in
                let productsInCategory = storeProducts.filter { $0.categoryId == category.id }
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
            // MARK: Store Header Card
            Section {
                StoreHeaderCard(store: store)
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
                    Section {
                        // Products grouped by category
                        ForEach(listItem.categorizedProducts, id: \.category.id) { categoryItem in
                            // Category header
                            HStack(spacing: AppTheme.Spacing.sm) {
                                Image(systemName: categoryItem.category.icon)
                                    .font(.subheadline)
                                    .foregroundStyle(categoryItem.category.visualColor)
                                Text(categoryItem.category.name)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("(\(categoryItem.products.count))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, AppTheme.Spacing.md)
                            .padding(.vertical, AppTheme.Spacing.xs)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            
                            // Products in this category
                            ForEach(categoryItem.products) { product in
                                InteractiveProductCard(
                                    product: product,
                                    list: listItem.list,
                                    listViewModel: listViewModel
                                )
                                .listRowInsets(EdgeInsets(top: AppTheme.Spacing.xs, leading: AppTheme.Spacing.md, bottom: AppTheme.Spacing.xs, trailing: AppTheme.Spacing.md))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                            }
                        }
                    } header: {
                        HStack {
                            Text(listItem.list.name)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            // Progress and actions
                            let completedCount = listItem.categorizedProducts.flatMap { $0.products }.filter { listItem.list.isProductChecked($0.id) }.count
                            let totalCount = listItem.categorizedProducts.flatMap { $0.products }.count
                            
                            HStack(spacing: AppTheme.Spacing.md) {
                                // Uncheck All Button
                                if completedCount > 0 {
                                    Button(action: { clearCheckedItems(for: listItem.list) }) {
                                        Text("Uncheck All")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundStyle(.red)
                                    }
                                }
                                
                                // Progress indicator
                                Text("\(completedCount)/\(totalCount)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(completedCount == totalCount ? .green : .secondary)
                            }
                        }
                        .textCase(nil)
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .navigationTitle(store.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Helper Methods
    
    /// Clears all checked items from the specified list
    private func clearCheckedItems(for list: ShoppingList) {
        guard var currentList = listViewModel.shoppingLists.first(where: { $0.id == list.id }) else {
            return
        }
        currentList.checkedProductIds.removeAll()
        listViewModel.updateList(currentList)
    }
}

// MARK: - Store Header Card

/// Header card showing store icon, name, and type badge
/// Uses color coding based on store type for visual distinction
private struct StoreHeaderCard: View {
    let store: Store
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // MARK: Store Icon
            // Large circular icon with gradient background
            ZStack {
                Circle()
                    .fill(storeColor.gradient)
                    .frame(width: 80, height: 80)
                
                Image(systemName: storeIcon)
                    .font(.system(size: 35, weight: .medium))
                    .foregroundStyle(.white)
            }
            
            // MARK: Store Info
            VStack(spacing: AppTheme.Spacing.sm) {
                // Store name
                Text(store.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                // Store type badge
                Text(store.type.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(storeColor)
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.vertical, AppTheme.Spacing.xs)
                    .background(storeColor.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.xl)
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
    
    /// Returns the appropriate SF Symbol icon for each store type
    private var storeIcon: String {
        switch store.type {
        case .grocery: return "cart.fill"
        case .pharmacy: return "cross.case.fill"
        case .hardware: return "hammer.fill"
        case .hypermarket: return "storefront.fill"
        }
    }
    
    /// Returns the color associated with each store type
    private var storeColor: Color {
        switch store.type {
        case .grocery: return .green
        case .pharmacy: return .red
        case .hardware: return .orange
        case .hypermarket: return .blue
        }
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

// MARK: - Interactive Product Card

/// Product card with checkbox functionality for store shopping lists
/// Reuses the same design as ListDetailView but adapted for store context
private struct InteractiveProductCard: View {
    let product: Product
    let list: ShoppingList
    @ObservedObject var listViewModel: ListViewModel
    
    private var isChecked: Bool {
        // Get the latest list state from view model
        guard let currentList = listViewModel.shoppingLists.first(where: { $0.id == list.id }) else {
            return false
        }
        return currentList.isProductChecked(product.id)
    }
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Checkbox
            Button(action: toggleProduct) {
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
    }
    
    private func toggleProduct() {
        // Get mutable copy of the current list
        guard var currentList = listViewModel.shoppingLists.first(where: { $0.id == list.id }) else {
            return
        }
        currentList.toggleProductChecked(product.id)
        listViewModel.updateList(currentList)
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
    let storeViewModel = StoreViewModel()
    let productViewModel = ProductViewModel()
    let listViewModel = ListViewModel()
    listViewModel.initializeSampleLists(with: productViewModel.products)
    let store = storeViewModel.stores.first!
    return NavigationStack {
        StoreDetailView(
            store: store,
            viewModel: storeViewModel,
            productViewModel: productViewModel,
            listViewModel: listViewModel
        )
    }
}
