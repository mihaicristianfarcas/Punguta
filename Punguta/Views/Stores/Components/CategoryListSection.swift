//
//  CategoryListSection.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 21.10.2025.
//

import SwiftUI

/// Section displaying and managing store categories
/// Allows adding categories and reordering via drag-and-drop
struct CategoryListSection: View {
    @Binding var selectedCategories: [UUID]
    let categories: [Category]
    let storeTypeColor: Color
    let onAddCategory: () -> Void
    let onMove: (IndexSet, Int) -> Void
    
    // Filter out already selected categories
    private var availableCategories: [Category] {
        categories.filter { !selectedCategories.contains($0.id) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header with add button
            CategorySectionHeader(
                storeTypeColor: storeTypeColor,
                canAddMore: !availableCategories.isEmpty,
                onAddCategory: onAddCategory
            )
            
            // Empty state or category list
            if selectedCategories.isEmpty {
                EmptyCategoryState()
            } else {
                CategoryList(
                    selectedCategories: $selectedCategories,
                    categories: categories,
                    onMove: onMove
                )
            }
        }
    }
}

/// Header with title and add button
private struct CategorySectionHeader: View {
    let storeTypeColor: Color
    let canAddMore: Bool
    let onAddCategory: () -> Void
    
    var body: some View {
        HStack {
            Text("Categories")
                .font(.headline)
                .foregroundStyle(.primary)
            
            Spacer()
            
            Button(action: onAddCategory) {
                HStack(spacing: 4) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                    Text("Add")
                        .font(.subheadline.weight(.medium))
                }
                .foregroundStyle(storeTypeColor)
            }
            .disabled(!canAddMore)
        }
        .padding(.horizontal, 35)
    }
}

/// Empty state when no categories are selected
private struct EmptyCategoryState: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "tag.slash")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)
            Text("No categories yet")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Tap Add to select categories")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 35)
    }
}

/// List of selected categories with drag-to-reorder
private struct CategoryList: View {
    @Binding var selectedCategories: [UUID]
    let categories: [Category]
    let onMove: (IndexSet, Int) -> Void
    
    var body: some View {
        List {
            ForEach(Array(selectedCategories.enumerated()), id: \.element) { index, categoryId in
                if let category = categories.first(where: { $0.id == categoryId }) {
                    CategoryRowView(category: category)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                }
            }
            .onMove { source, destination in
                onMove(source, destination)
            }
        }
        .listStyle(.plain)
        .listRowBackground(Color.clear)
        .frame(height: CGFloat(selectedCategories.count) * 56)
        .scrollDisabled(true)
        .padding(.top, 4)
        .padding(.horizontal, 25)
    }
}

/// Individual category row with icon and name
private struct CategoryRowView: View {
    let category: Category
    
    var body: some View {
        HStack(spacing: 12) {
            // Category icon badge
            CategoryIconBadge(
                icon: category.icon,
                color: category.visualColor
            )
            
            // Category name
            Text(category.name)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
        }
        .padding(.leading, 8)
    }
}

/// Circular badge with category icon
private struct CategoryIconBadge: View {
    let icon: String
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color.gradient)
                .frame(width: 32, height: 32)
                .overlay(
                    Circle()
                        .strokeBorder(Color.gray.opacity(0.2), lineWidth: 1)
                )
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
        }
    }
}
