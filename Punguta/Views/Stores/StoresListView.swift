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
    
    // MARK: Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                AppTheme.Colors.groupedBackground
                    .ignoresSafeArea()
                
                // Stores list
                List {
                    ForEach(viewModel.stores) { store in
                        NavigationLink(destination: StoreDetailView(store: store, viewModel: viewModel)) {
                            StoreRowView(store: store, viewModel: viewModel)
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
                        .buttonStyle(.plain)
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
                                storeToEdit = store
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(AppTheme.Colors.warning)
                            
                            Button {
                                storeToDelete = store
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
            .navigationTitle("My Stores")
            .navigationBarTitleDisplayMode(.large)
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
            .overlay {
                if viewModel.stores.isEmpty {
                    EmptyStateView(
                        icon: "storefront",
                        title: "No Stores Yet",
                        message: "Add your first store to start organizing your shopping",
                        actionTitle: "Add Store",
                        action: { showingAddStore = true }
                    )
                }
            }
        }
    }
}

// MARK: - Store Row View

/// Displays a single store in the list
/// Shows store name, type, location, and category count
private struct StoreRowView: View {
    
    // MARK: Properties
    
    let store: Store
    let viewModel: StoreViewModel
    
    // MARK: Body
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Store icon
            ZStack {
                Circle()
                    .fill(storeColor.gradient)
                    .frame(width: AppTheme.IconSize.huge, height: AppTheme.IconSize.huge)
                
                Image(systemName: storeIcon)
                    .font(.system(size: AppTheme.IconSize.lg, weight: AppTheme.FontWeight.md))
                    .foregroundStyle(.white)
            }
            
            // Store details
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                // Store name and type
                HStack {
                    Text(store.name)
                        .font(.title3)
                        .fontWeight(AppTheme.FontWeight.md)
                        .foregroundStyle(AppTheme.Colors.primaryText)
                        .lineLimit(1)
                    
                    Text(store.type.rawValue)
                        .font(.subheadline)
                        .fontWeight(AppTheme.FontWeight.md)
                        .foregroundStyle(storeColor)
                        .lineLimit(1)
                }
                
                // Location
                if let address = store.location.address {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.caption2)
                        Text(address)
                            .font(.subheadline)
                            .lineLimit(1)
                    }
                    .foregroundStyle(AppTheme.Colors.secondaryText)
                }
                
                // Category count
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: "tag.fill")
                        .font(.caption2)
                    Text("\(store.categoryOrder.count) categories")
                        .font(.caption)
                        .fontWeight(AppTheme.FontWeight.md)
                }
                .foregroundStyle(AppTheme.Colors.secondaryText)
                .padding(.top, AppTheme.Spacing.xs)
            }
            
            Spacer()
        }
        .padding(AppTheme.Spacing.md)
    }
    
    // MARK: Computed Properties
    
    /// Icon representing the store type
    private var storeIcon: String {
        switch store.type {
        case .grocery: return "cart.fill"
        case .pharmacy: return "cross.case.fill"
        case .hardware: return "hammer.fill"
        case .hypermarket: return "storefront.fill"
        }
    }
    
    /// Color associated with the store type
    private var storeColor: Color {
        switch store.type {
        case .grocery: return AppTheme.Colors.success
        case .pharmacy: return AppTheme.Colors.destructive
        case .hardware: return AppTheme.Colors.warning
        case .hypermarket: return AppTheme.Colors.primaryAction
        }
    }
}

// MARK: - Preview

#Preview {
    StoresListView()
}
