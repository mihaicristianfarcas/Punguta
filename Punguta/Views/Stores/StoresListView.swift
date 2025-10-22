//
//  StoresListView.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 20.10.2025.
//

import SwiftUI
import MapKit

// MARK: - Stores List View

/// Main view for browsing and managing stores
///
/// **Features**:
/// - List of all stores with details
/// - CRUD operations (Create, Read, Update, Delete)
/// - Swipe actions for quick edit/delete
/// - Empty state with call-to-action
struct StoresListView: View {
    
    // MARK: Properties
    
    /// View model managing stores
    @StateObject private var viewModel = StoreViewModel()
    
    /// Controls add store sheet visibility
    @State private var showingAddStore = false
    
    /// Store currently being edited
    @State private var storeToEdit: Store?
    
    /// Store marked for deletion
    @State private var storeToDelete: Store?
    
    /// Controls delete confirmation alert
    @State private var showingDeleteConfirmation = false
    
    /// Current search query
    @State private var searchText = ""
    
    /// Currently selected store type filter (nil = all types)
    @State private var selectedStoreType: StoreType?
    
    // MARK: Computed Properties
    
    /// Stores filtered by search and type
    /// Sorted alphabetically by name
    private var filteredStores: [Store] {
        // Start with all stores
        let allStores: [Store] = viewModel.stores

        // Apply search filter
        let searchFiltered: [Store]
        if searchText.isEmpty {
            searchFiltered = allStores
        } else {
            let query = searchText.lowercased()
            searchFiltered = allStores.filter { store in
                let nameMatch = store.name.lowercased().contains(query)
                let addressText = store.location.address?.lowercased() ?? ""
                let addressMatch = addressText.contains(query)
                return nameMatch || addressMatch
            }
        }

        // Apply type filter
        let typeFiltered: [Store]
        if let storeType = selectedStoreType {
            typeFiltered = searchFiltered.filter { $0.type == storeType }
        } else {
            typeFiltered = searchFiltered
        }

        // Sort alphabetically by name
        let sorted = typeFiltered.sorted { lhs, rhs in
            lhs.name < rhs.name
        }

        return sorted
    }
    
    // MARK: Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                // Stores list with filter pills
                List {
                    // Store type filter pills
                    Section {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: AppTheme.Spacing.sm) {
                                FilterPillView(
                                    title: "All",
                                    isSelected: selectedStoreType == nil,
                                    action: { selectedStoreType = nil }
                                )
                                
                                ForEach(StoreType.allCases, id: \.self) { storeType in
                                    FilterPillView(
                                        title: storeType.rawValue,
                                        icon: storeTypeIcon(storeType),
                                        color: storeTypeColor(storeType),
                                        isSelected: selectedStoreType == storeType,
                                        action: {
                                            selectedStoreType = selectedStoreType == storeType ? nil : storeType
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
                    
                    // Stores or empty states
                    if filteredStores.isEmpty {
                        if viewModel.stores.isEmpty {
                            Section {
                                EmptyStateView(
                                    icon: "storefront",
                                    title: "No Stores Yet",
                                    message: "Add your first store to start organizing your shopping"
                                )
                                .frame(maxWidth: .infinity)
                                .listRowInsets(EdgeInsets())
                            }
                        } else {
                            Section {
                                StoresNoResultsView()
                                    .frame(maxWidth: .infinity)
                                    .listRowInsets(EdgeInsets())
                            }
                        }
                    } else {
                        // Stores grouped by type
                        let storesByType: [StoreType: [Store]] = {
                            var dict: [StoreType: [Store]] = [:]
                            for type in StoreType.allCases {
                                dict[type] = filteredStores.filter { $0.type == type }
                            }
                            return dict
                        }()
                        
                        ForEach(StoreType.allCases, id: \.self) { storeType in
                            if let storesOfType = storesByType[storeType], !storesOfType.isEmpty {
                                Section {
                                    ForEach(storesOfType) { store in
                                        NavigationLink(destination: StoreDetailView(store: store, viewModel: viewModel)) {
                                            StoreRowView(
                                                store: store,
                                                viewModel: viewModel,
                                                onEdit: { storeToEdit = store },
                                                onDelete: {
                                                    storeToDelete = store
                                                    showingDeleteConfirmation = true
                                                }
                                            )
                                        }
                                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            Button() {
                                                storeToDelete = store
                                                showingDeleteConfirmation = true
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                            .tint(.red)
                                            
                                            Button {
                                                storeToEdit = store
                                            } label: {
                                                Label("Edit", systemImage: "pencil")
                                            }
                                            .tint(.orange)
                                        }
                                    }
                                } header: {
                                    HStack {
                                        Image(systemName: storeTypeIcon(storeType))
                                            .foregroundStyle(storeTypeColor(storeType))
                                        Text(storeType.rawValue)
                                    }
                                    .font(.headline)
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("My Stores")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search stores")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddStore = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddStore) {
            AddEditStoreView(viewModel: viewModel)
        }
        .sheet(item: $storeToEdit) { store in
            AddEditStoreView(viewModel: viewModel, storeToEdit: store)
        }
        .alert(
            "Delete Store",
            isPresented: $showingDeleteConfirmation,
            presenting: storeToDelete
        ) { store in
            Button("Cancel", role: .cancel) {
                storeToDelete = nil
            }
            Button("Delete", role: .destructive) {
                withAnimation {
                    viewModel.deleteStore(store)
                }
                storeToDelete = nil
            }
        } message: { store in
            Text("Are you sure you want to delete '\(store.name)'? This action cannot be undone.")
        }
    }
    
    
    // MARK: Helper Methods
    
    /// Returns icon for store type
    private func storeTypeIcon(_ type: StoreType) -> String {
        switch type {
        case .grocery: return "cart.fill"
        case .pharmacy: return "cross.case.fill"
        case .hardware: return "hammer.fill"
        case .hypermarket: return "storefront.fill"
        }
    }
    
    /// Returns color for store type
    private func storeTypeColor(_ type: StoreType) -> Color {
        switch type {
        case .grocery: return AppTheme.Colors.success
        case .pharmacy: return AppTheme.Colors.destructive
        case .hardware: return AppTheme.Colors.warning
        case .hypermarket: return AppTheme.Colors.primaryAction
        }
    }
    
    // MARK: - No Results View
    
    /// Displays when search returns no results
    private struct StoresNoResultsView: View {
        
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
                    
                    Text("No stores found")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(AppTheme.Spacing.xl)
        }
    }
    
    // MARK: - Store Row View
    
    /// Displays a single store in the list
    /// Shows store name, type, location, and category count
    private struct StoreRowView: View {
        
        // MARK: Properties
        
        let store: Store
        let viewModel: StoreViewModel
        let onEdit: () -> Void
        let onDelete: () -> Void
        
        // MARK: Body
        
        var body: some View {
            HStack(spacing: AppTheme.Spacing.md) {
                // Store details
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    // Store name and type badge
                    
                Text(store.name)
                    .font(.title3)
                    .fontWeight(AppTheme.FontWeight.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    
                    // Location
                    if let address = store.location.address {
                        Text(address)
                            .font(.subheadline)
                            .foregroundStyle(.primary.opacity(0.9))
                            .lineLimit(1)
                    }
                    
                    // Category count
                    Text("\(store.categoryOrder.count) categories")
                        .font(.caption)
                        .fontWeight(AppTheme.FontWeight.md)
                        .foregroundStyle(.secondary)
                        .padding(.top, AppTheme.Spacing.xs)
                }
                
                Spacer()
            }
            .padding(AppTheme.Spacing.md)
            .contentShape(Rectangle())
        }
    }
}
    
// MARK: - Preview

#Preview {
    StoresListView()
}

