//
//  StoreDetailView.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 21.10.2025.
//

import SwiftUI
import MapKit

/// Detail view for a store showing its information and categories
struct StoreDetailView: View {
    let store: Store
    let viewModel: StoreViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Store Header Card
                    StoreHeaderCard(store: store)
                    
                    // Location Section
                    LocationSection(store: store)
                    
                    // Categories Section
                    CategoriesSection(store: store, viewModel: viewModel)
                }
                .padding(.vertical, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(store.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Store Header Card
private struct StoreHeaderCard: View {
    let store: Store
    
    var body: some View {
        VStack(spacing: 16) {
            // Store Icon
            ZStack {
                Circle()
                    .fill(storeColor.gradient)
                    .frame(width: 80, height: 80)
                
                Image(systemName: storeIcon)
                    .font(.system(size: 35, weight: .medium))
                    .foregroundStyle(.white)
            }
            
            // Store Info
            VStack(spacing: 8) {
                Text(store.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(store.type.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(storeColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(storeColor.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 16)
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
}

// MARK: - Location Section
private struct LocationSection: View {
    let store: Store
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Location")
                .font(.headline)
                .foregroundStyle(.primary)
                .padding(.horizontal, 16)
            
            VStack(spacing: 12) {
                // Address
                if let address = store.location.address {
                    HStack(spacing: 12) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.red)
                        
                        Text(address)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Coordinates
                HStack(spacing: 12) {
                    Image(systemName: "location.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.blue)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Coordinates")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text("\(store.location.latitude, specifier: "%.4f"), \(store.location.longitude, specifier: "%.4f")")
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                    }
                    
                    Spacer()
                }
                .padding(16)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Categories Section
private struct CategoriesSection: View {
    let store: Store
    let viewModel: StoreViewModel
    
    private var orderedCategories: [Category] {
        store.categoryOrder.compactMap { categoryId in
            viewModel.categories.first { $0.id == categoryId }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Categories")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text("\(orderedCategories.count)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 16)
            
            if orderedCategories.isEmpty {
                EmptyCategoriesState()
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(orderedCategories) { category in
                        CategoryCard(category: category)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - Category Card
private struct CategoryCard: View {
    let category: Category
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(category.visualColor.gradient)
                    .frame(width: 50, height: 50)
                
                Image(systemName: category.icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
            }
            
            Text(category.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Empty Categories State
private struct EmptyCategoriesState: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "tag.slash")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            
            Text("No categories")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }
}

// MARK: - Preview
#Preview {
    let viewModel = StoreViewModel()
    let store = viewModel.stores.first!
    return StoreDetailView(store: store, viewModel: viewModel)
}
