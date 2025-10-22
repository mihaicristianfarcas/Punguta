//
//  CategoryIconView.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 21.10.2025.
//

import SwiftUI

/// Reusable category icon component
/// Displays a category icon with consistent styling
struct CategoryIconView: View {
    
    // MARK: - Properties
    
    let category: Category
    let size: CGFloat
    
    // MARK: - Initializer
    
    init(category: Category, size: CGFloat = AppTheme.IconSize.xxl) {
        self.category = category
        self.size = size
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Circle()
                .fill(category.visualColor.opacity(0.2))
                .frame(width: size, height: size)
            
            Image(systemName: category.icon)
                .font(.system(size: size * 0.5))
                .foregroundStyle(category.visualColor)
        }
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: AppTheme.Spacing.md) {
        ForEach(Category.defaultCategories.prefix(5)) { category in
            VStack {
                CategoryIconView(category: category)
                Text(category.name)
                    .font(.caption2)
            }
        }
    }
    .padding()
}
