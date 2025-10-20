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
    @State private var showingEditStore = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.stores) { store in
                    StoreRowView(store: store, viewModel: viewModel)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedStore = store
                            showingEditStore = true
                        }
                }
                .onDelete(perform: viewModel.deleteStores)
            }
            .navigationTitle("Stores")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddStore = true }) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingAddStore) {
                AddEditStoreView(viewModel: viewModel)
            }
            .sheet(item: $selectedStore) { store in
                AddEditStoreView(viewModel: viewModel, storeToEdit: store)
            }
            .overlay {
                if viewModel.stores.isEmpty {
                    ContentUnavailableView(
                        "No Stores",
                        systemImage: "storefront",
                        description: Text("Add your first store to get started")
                    )
                }
            }
        }
    }
}

struct StoreRowView: View {
    let store: Store
    let viewModel: StoreViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: storeIcon)
                    .foregroundStyle(.blue)
                    .font(.title2)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.name)
                        .font(.headline)
                    
                    Text(store.type.rawValue)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    if let address = store.location.address {
                        Label(address, systemImage: "mappin.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
                    .font(.caption)
            }
            
            // Category pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(viewModel.categories(for: store).prefix(5)) { category in
                        Text(category.name)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .foregroundStyle(.blue)
                            .clipShape(Capsule())
                    }
                    
                    if store.categoryOrder.count > 5 {
                        Text("+\(store.categoryOrder.count - 5)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var storeIcon: String {
        switch store.type {
        case .grocery: return "cart.fill"
        case .pharmacy: return "cross.case.fill"
        case .hardware: return "hammer.fill"
        case .convenience: return "storefront.fill"
        }
    }
}

#Preview {
    StoresListView()
}
