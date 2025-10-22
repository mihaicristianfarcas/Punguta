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
    
    // MARK: Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                AppTheme.Colors.groupedBackground
                    .ignoresSafeArea()
                
                // Lists
                List {
                    ForEach(viewModel.shoppingLists) { list in
                        NavigationLink(destination: ListDetailView(
                            list: list,
                            productViewModel: productViewModel,
                            listViewModel: viewModel
                        )) {
                            ListRowView(list: list, productViewModel: productViewModel)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                                .fill(AppTheme.Colors.cardBackground)
                                .shadow(
                                    color: AppTheme.Shadow.md.color,
                                    radius: AppTheme.Shadow.md.radius,
                                    x: AppTheme.Shadow.md.x,
                                    y: AppTheme.Shadow.md.y
                                )
                        )
                        .listRowInsets(EdgeInsets(
                            top: AppTheme.Spacing.xs + 2,
                            leading: AppTheme.Spacing.md,
                            bottom: AppTheme.Spacing.xs + 2,
                            trailing: AppTheme.Spacing.md
                        ))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button {
                                listToEdit = list
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(AppTheme.Colors.warning)
                            
                            Button {
                                listToDelete = list
                                showingDeleteConfirmation = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(AppTheme.Colors.destructive)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("My Lists")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddList = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(AppTheme.Colors.primaryAction)
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
            .overlay {
                if viewModel.shoppingLists.isEmpty {
                    EmptyStateView(
                        icon: "list.clipboard",
                        title: "No Lists Yet",
                        message: "Create your first shopping list to get started",
                        actionTitle: "Create List",
                        action: { showingAddList = true }
                    )
                }
            }
        }
    }
}

// MARK: - List Row View

/// Displays a single shopping list in the list view
/// Shows list name, item count, and progress statistics
private struct ListRowView: View {
    
    // MARK: Properties
    
    let list: ShoppingList
    let productViewModel: ProductViewModel
    
    // MARK: Computed Properties
    
    /// All products in this list
    private var products: [Product] {
        list.productIds.compactMap { id in
            productViewModel.products.first { $0.id == id }
        }
    }
    
    /// Number of completed products
    private var completedCount: Int {
        products.filter { $0.isChecked }.count
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
            // List icon
            ZStack {
                Circle()
                    .fill(listColor.gradient)
                    .frame(width: AppTheme.IconSize.huge, height: AppTheme.IconSize.huge)
                
                Image(systemName: "list.bullet.clipboard.fill")
                    .font(.system(size: AppTheme.IconSize.lg, weight: AppTheme.FontWeight.md))
                    .foregroundStyle(.white)
            }
            
            // List details
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(list.name)
                    .font(.title3)
                    .fontWeight(AppTheme.FontWeight.md)
                    .foregroundStyle(AppTheme.Colors.primaryText)
                
                HStack(spacing: AppTheme.Spacing.md) {
                    // Item count
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: "cart.fill")
                            .font(.caption)
                        Text("\(products.count) \(products.count == 1 ? "item" : "items")")
                            .font(.subheadline)
                    }
                    .foregroundStyle(AppTheme.Colors.secondaryText)
                    
                    // Progress
                    if !products.isEmpty {
                        HStack(spacing: AppTheme.Spacing.xs) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(completedCount == products.count ? AppTheme.Colors.success : AppTheme.Colors.secondaryText)
                            Text("\(completedCount)/\(products.count)")
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.Colors.secondaryText)
                        }
                    }
                }
                
                // Last updated
                Text("Updated \(list.updatedAt, style: .relative) ago")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            
            Spacer()
        }
        .padding(AppTheme.Spacing.md)
    }
}

// MARK: - Preview

#Preview {
    ListsView(productViewModel: ProductViewModel())
}
