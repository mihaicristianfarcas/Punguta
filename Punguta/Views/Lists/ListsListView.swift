//
//  ListsView.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 21.10.2025.
//

import SwiftUI

// MARK: - Lists View

/// Main view for browsing and managing shopping lists
///
/// **Features**:
/// - List of all shopping lists with stats
/// - CRUD operations (Create, Read, Update, Delete)
/// - Swipe actions for quick edit/delete
/// - Empty state with call-to-action
/// - Coordination between ListViewModel and ProductViewModel
struct ListsView: View {
    
    // MARK: Properties
    
    /// Product view model for accessing products
    @ObservedObject var productViewModel: ProductViewModel
    
    /// Shared view model managing lists
    @EnvironmentObject private var viewModel: ListViewModel
    
    /// Controls add list sheet visibility
    @State private var showingAddList = false
    
    /// List currently being edited
    @State private var listToEdit: ShoppingList?
    
    /// List marked for deletion
    @State private var listToDelete: ShoppingList?
    
    /// Controls delete confirmation alert
    @State private var showingDeleteConfirmation = false
    
    /// Current search query
    @State private var searchText = ""
    
    /// Currently selected status filter (nil = all, true = completed, false = active)
    @State private var selectedStatusFilter: CompletionStatus?
    
    /// Status filter options
    private enum CompletionStatus: String, CaseIterable {
        case active = "Active"
        case completed = "Completed"
    }
    
    // MARK: Computed Properties
    
    /// Lists filtered by search and status
    /// Sorted by most recently updated
    private var filteredLists: [ShoppingList] {
        var filtered = viewModel.shoppingLists
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply status filter
        if let status = selectedStatusFilter {
            filtered = filtered.filter { list in
                let products = list.productIds.compactMap { id in
                    productViewModel.products.first { $0.id == id }
                }
                let completedCount = list.checkedProductIds.count
                
                switch status {
                case .active:
                    return completedCount < products.count || products.isEmpty
                case .completed:
                    return !products.isEmpty && completedCount == products.count
                }
            }
        }
        
        return filtered.sorted { $0.updatedAt > $1.updatedAt }
    }
    
    // MARK: Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                // Lists with filter pills
                List {
                    // Status filter pills
                    Section {
                        StatusFilterPills(selectedStatusFilter: $selectedStatusFilter)
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    
                    
                    // Lists or empty states
                    if filteredLists.isEmpty {
                        if viewModel.shoppingLists.isEmpty {
                            Section {
                                EmptyStateView(
                                    icon: "list.clipboard",
                                    title: "No Lists Yet",
                                    message: "Create your first shopping list to get started"
                                )
                                .frame(maxWidth: .infinity)
                                .listRowInsets(EdgeInsets())
                            }
                        } else {
                            Section {
                                ListsNoResultsView()
                                    .frame(maxWidth: .infinity)
                                    .listRowInsets(EdgeInsets())
                                    .listRowBackground(Color.clear)
                            }
                        }
                    } else {
                        // Lists
                        Section {
                            ForEach(filteredLists) { list in
                                NavigationLink(destination: ListDetailView(
                                    list: list,
                                    productViewModel: productViewModel,
                                    listViewModel: viewModel
                                )) {
                                    ListRowView(
                                        list: list,
                                        productViewModel: productViewModel,
                                        onEdit: { listToEdit = list },
                                        onDelete: {
                                            listToDelete = list
                                            showingDeleteConfirmation = true
                                        }
                                    )
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button() {
                                        listToDelete = list
                                        showingDeleteConfirmation = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    .tint(.red)
                                    
                                    Button {
                                        listToEdit = list
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.orange)
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("My Lists")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search lists")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddList = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddList) {
                AddEditListView(listViewModel: viewModel, productViewModel: productViewModel)
            }
            .sheet(item: $listToEdit) { list in
                AddEditListView(listViewModel: viewModel, productViewModel: productViewModel, listToEdit: list)
            }
            .alert(
                "Delete List",
                isPresented: $showingDeleteConfirmation,
                presenting: listToDelete
            ) { list in
                Button("Cancel", role: .cancel) {
                    listToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    withAnimation {
                        viewModel.deleteList(list)
                    }
                    listToDelete = nil
                }
            } message: { list in
                Text("Are you sure you want to delete '\(list.name)'? This action cannot be undone.")
            }
        }
    }
    
    // MARK: - Status Filter Pills
    
    private struct StatusFilterPills: View {
        @Binding var selectedStatusFilter: CompletionStatus?
        
        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    FilterPillView(
                        title: "All",
                        isSelected: selectedStatusFilter == nil,
                        action: { selectedStatusFilter = nil }
                    )
                    
                    ForEach(CompletionStatus.allCases, id: \.self) { status in
                        FilterPillView(
                            title: status.rawValue,
                            icon: status == .completed ? "checkmark.circle.fill" : "circle.dashed",
                            color: status == .completed ? AppTheme.Colors.success : AppTheme.Colors.primaryAction,
                            isSelected: selectedStatusFilter == status,
                            action: {
                                selectedStatusFilter = selectedStatusFilter == status ? nil : status
                            }
                        )
                    }
                }
                .padding(AppTheme.Spacing.sm)
            }
        }
    }
    
    // MARK: - No Results View
    
    /// Displays when search returns no results
    private struct ListsNoResultsView: View {
        
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
                    
                    Text("No lists found")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(AppTheme.Spacing.xl)
        }
    }
    
    // MARK: - List Row View
    
    /// Displays a single shopping list in the list view
    /// Shows list name, item count, and progress statistics
    private struct ListRowView: View {
        
        // MARK: Properties
        
        let list: ShoppingList
        let productViewModel: ProductViewModel
        let onEdit: () -> Void
        let onDelete: () -> Void
        
        // MARK: Computed Properties
        
        /// All products in this list
        private var products: [Product] {
            list.productIds.compactMap { id in
                productViewModel.products.first { $0.id == id }
            }
        }
        
        /// Number of completed products
        private var completedCount: Int {
            list.checkedProductIds.count
        }
        
        /// Color for the list icon
        private var listColor: Color {
            let colors = AppTheme.Colors.categoryColors
            let index = abs(list.name.hashValue) % colors.count
            return colors[index]
        }
        
        // MARK: Body
        
        var body: some View {
            HStack(spacing: AppTheme.Spacing.md) {
                // List details
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    
                    HStack {
                        // List name
                        Text(list.name)
                            .font(.title3)
                            .fontWeight(AppTheme.FontWeight.semibold)
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                     
                        if (!products.isEmpty && completedCount == products.count) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.green)
                        }
                    }
                    HStack(spacing: AppTheme.Spacing.md) {
                        // Item count
                        Text("\(products.count) \(products.count == 1 ? "item" : "items")")
                            .font(.subheadline)
                            .foregroundStyle(.primary.opacity(0.9))
                        
                        // Progress
                        if !products.isEmpty {
                            Text("•")
                                .foregroundStyle(.primary.opacity(0.6))
                            
                            Text("\(completedCount)/\(products.count) completed")
                                .font(.subheadline)
                                .foregroundStyle(.primary.opacity(0.9))
                        }
                    }
                    
                    // Last updated
                    Text("Updated \(list.updatedAt, style: .relative) ago")
                        .font(.caption)
                        .foregroundStyle(.secondary)
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
    ListsView(productViewModel: ProductViewModel())
        .environmentObject(ListViewModel())
}

