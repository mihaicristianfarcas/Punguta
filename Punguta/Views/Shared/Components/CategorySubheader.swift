//
//  CategorySubheader.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 23.10.2025.
//

import SwiftUI

// MARK: - Category Subheader

/// Reusable category subheader showing icon, name, and item count
/// Used in StoreDetailView to organize products by category
struct CategorySubheader: View {
    
    // MARK: Properties
    
    let category: Category
    let itemCount: Int
    
    // MARK: Body
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: category.icon)
                .font(.subheadline)
                .foregroundStyle(category.visualColor)
            
            Text(category.name)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Spacer()
            
            Text("(\(itemCount))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, AppTheme.Spacing.xs)
        .padding(.horizontal, AppTheme.Spacing.sm)
    }
}

// MARK: - Preview

#Preview {
    List {
        CategorySubheader(
            category: Category.defaultCategories[0],
            itemCount: 5
        )
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        
        Text("Product 1")
        Text("Product 2")
        Text("Product 3")
    }
}
