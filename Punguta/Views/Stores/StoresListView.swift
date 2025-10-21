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
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.stores) { store in
                        StoreRowView(store: store, viewModel: viewModel)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedStore = store
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    withAnimation {
                                        viewModel.deleteStore(store)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .padding(.top, 8)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("My Stores")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: { showingAddStore = true }) {
//                        HStack(spacing: 4) {
//                            Image(systemName: "plus.circle.fill")
//                            Text("Add Store")
//                                .fontWeight(.semibold)
//                        }
//                        .foregroundStyle(.blue)
//                    }
//                }
//            }
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingAddStore) {
                AddEditStoreView(viewModel: viewModel)
            }
            .sheet(item: $selectedStore) { store in
                AddEditStoreView(viewModel: viewModel, storeToEdit: store)
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
                    Text(store.name)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                    
                    HStack(spacing: 4) {
                        Text(store.type.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(storeColor)
                        
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
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding(16)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }
    
    private var storeIcon: String {
        switch store.type {
        case .grocery: return "cart.fill"
        case .pharmacy: return "cross.case.fill"
        case .hardware: return "hammer.fill"
        case .convenience: return "storefront.fill"
        }
    }
    
    private var storeColor: Color {
        switch store.type {
        case .grocery: return .green
        case .pharmacy: return .red
        case .hardware: return .orange
        case .convenience: return .blue
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
