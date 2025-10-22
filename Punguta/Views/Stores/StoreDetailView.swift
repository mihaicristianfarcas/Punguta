//
//  StoreDetailView.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 21.10.2025.
//

import SwiftUI
import MapKit

// MARK: - Store Detail View

/// Detailed view of a store with all its information
/// Features:
/// - Store header with icon, name, and type badge
/// - Location information (address and coordinates)
/// - Categories section showing store's category order
/// - Empty states for missing data
/// - Color-coded UI based on store type
struct StoreDetailView: View {
    
    // MARK: Properties
    
    /// The store being displayed
    let store: Store
    
    /// View model for accessing categories data
    let viewModel: StoreViewModel
    
    // MARK: Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.xl) {
                // MARK: Store Header Card
                // Displays store icon, name, and type
                StoreHeaderCard(store: store)
                
                // MARK: Location Section
                // Shows address and coordinates with map icons
                LocationSection(store: store)
                
                // MARK: Categories Section
                // Grid of categories in the store's custom order
                CategoriesSection(store: store, viewModel: viewModel)
            }
            .padding(.vertical, AppTheme.Spacing.lg)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(store.name)
        .navigationBarTitleDisplayMode(.inline)
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

// MARK: - Categories Section

/// Displays store's categories in their custom order
/// Shows a 2-column grid of category cards with count badge
private struct CategoriesSection: View {
    let store: Store
    let viewModel: StoreViewModel
    
    /// Categories in the store's custom ordering
    /// Resolves category IDs to full Category objects
    private var orderedCategories: [Category] {
        store.categoryOrder.compactMap { categoryId in
            viewModel.categories.first { $0.id == categoryId }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // Section header with count badge
            HStack {
                Text("Categories")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                // Count badge
                Text("\(orderedCategories.count)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, AppTheme.Spacing.sm)
                    .padding(.vertical, AppTheme.Spacing.xs)
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            
            // Grid of categories or empty state
            if orderedCategories.isEmpty {
                EmptyCategoriesState()
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: AppTheme.Spacing.md) {
                    ForEach(orderedCategories) { category in
                        CategoryCard(category: category)
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.md)
            }
        }
    }
}

// MARK: - Category Card

/// Individual category card showing icon and name
/// Color-coded based on category color
private struct CategoryCard: View {
    let category: Category
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            // Category icon with colored background
            ZStack {
                Circle()
                    .fill(category.visualColor.gradient)
                    .frame(width: 50, height: 50)
                
                Image(systemName: category.icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
            }
            
            // Category name
            Text(category.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.md)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md))
        .shadow(
            color: AppTheme.Shadow.sm.color,
            radius: AppTheme.Shadow.sm.radius,
            x: AppTheme.Shadow.sm.x,
            y: AppTheme.Shadow.sm.y
        )
    }
}

// MARK: - Empty Categories State

/// Empty state shown when store has no categories
private struct EmptyCategoriesState: View {
    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
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
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md))
        .padding(.horizontal, AppTheme.Spacing.md)
    }
}

// MARK: - Preview
#Preview {
    let viewModel = StoreViewModel()
    let store = viewModel.stores.first!
    return StoreDetailView(store: store, viewModel: viewModel)
}
