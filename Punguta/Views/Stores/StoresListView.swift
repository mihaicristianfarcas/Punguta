//
//  StoresListView.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 20.10.2025.
//

import SwiftUI
import MapKit

struct StoresListView: View {
    @StateObject private var viewModel = StoreViewModel()
    @State private var showingAddStore = false
    @State private var selectedStore: Store?
    @State private var storeToEdit: Store?
    @State private var showingStoreDetail = false
    @State private var storeToDelete: Store?
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                List {
                    ForEach(viewModel.stores) { store in
                        StoreRowView(store: store, viewModel: viewModel)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedStore = store
                                showingStoreDetail = true
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button {
                                    storeToEdit = store
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.orange)
                                
                                Button {
                                    storeToDelete = store
                                    showingDeleteConfirmation = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(.red)
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
            .sheet(isPresented: $showingStoreDetail) {
                if let store = selectedStore {
                    StoreDetailView(store: store, viewModel: viewModel)
                }
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
                    VStack(spacing: 20) {
                    
                        Image(systemName: "storefront")
                            .font(.system(size: 50))
                            .foregroundStyle(.secondary)
                        
                        VStack(spacing: 14) {
                            Text("No Stores Yet!")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Add your first store to start organizing your shopping")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        
                        Button(action: { showingAddStore = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Store")
                                    .fontWeight(.semibold)
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.blue.gradient)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                        }
                        .padding(.top, 8)
                    }
                }
            }
        }
    }
}

struct StoreRowView: View {
    let store: Store
    let viewModel: StoreViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            // Header with icon and store name
            HStack(spacing: 10) {
                // Colorful icon background
                ZStack {
                    Circle()
                        .fill(storeColor.gradient)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: storeIcon)
                        .font(.system(size: 25, weight: .medium))
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 1) {
                    HStack {
                        Text(store.name)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        
                        Text(store.type.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(storeColor)
                            .lineLimit(1)
                    }
                    HStack(spacing: 4) {
                        if let address = store.location.address {
                            Text("at")
                                .foregroundStyle(.secondary)
                            
                            Text(address)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                    
                    // Category count badge
                    HStack(spacing: 4) {
                        Image(systemName: "tag")
                            .font(.caption2)
                        Text("\(store.categoryOrder.count) categories")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
                }
                
                Spacer()
                
                Image(systemName: "hand.tap")
                    .foregroundStyle(.tertiary)
                    .font(.system(size: 18, weight: .semibold))
            }
            .padding(16)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    private var storeIcon: String {
        switch store.type {
        case .grocery: return "cart.fill"
        case .pharmacy: return "cross.case.fill"
        case .hardware: return "hammer.fill"
        case .hypermarket: return "storefront.fill"
        }
    }
    
    private var storeColor: Color {
        switch store.type {
        case .grocery: return .green
        case .pharmacy: return .red
        case .hardware: return .orange
        case .hypermarket: return .blue
        }
    }
    
    private func categoryColor(for categoryName: String) -> Color {
        let colors: [Color] = [.purple, .pink, .indigo, .teal, .cyan, .mint]
        let index = abs(categoryName.hashValue) % colors.count
        return colors[index]
    }
}

#Preview {
    StoresListView()
}
