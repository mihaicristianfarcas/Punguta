//
//  CategorySelectorView.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 20.10.2025.
//

import SwiftUI

struct CategorySelectorView: View {
    @Environment(\.dismiss) private var dismiss
    
    let availableCategories: [Category]
    @Binding var selectedCategories: [UUID]
    
    @State private var searchText = ""
    
    private var filteredCategories: [Category] {
        if searchText.isEmpty {
            return availableCategories
        }
        return availableCategories.filter { category in
            category.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredCategories) { category in
                        Button(action: { 
                            withAnimation(.spring(response: 0.3)) {
                                toggleCategory(category)
                            }
                        }) {
                            HStack(spacing: 12) {
                                // Category icon
                                ZStack {
                                    Circle()
                                        .fill(categoryColor(for: category.name).opacity(0.15))
                                        .frame(width: 50, height: 50)
                                    
                                    Image(systemName: categoryIcon(for: category.name))
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundStyle(categoryColor(for: category.name))
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(category.name)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    
                                    Text("\(category.keywords.count) items")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                // Checkmark
                                if selectedCategories.contains(category.id) {
                                    ZStack {
                                        Circle()
                                            .fill(categoryColor(for: category.name).gradient)
                                            .frame(width: 32, height: 32)
                                        
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(.white)
                                    }
                                } else {
                                    Circle()
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                                        .frame(width: 32, height: 32)
                                }
                            }
                            .padding(16)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .searchable(text: $searchText, prompt: "Search categories")
            .navigationTitle("Select Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func categoryColor(for categoryName: String) -> Color {
        let colors: [Color] = [.purple, .pink, .indigo, .teal, .cyan, .mint, .orange, .green]
        let index = abs(categoryName.hashValue) % colors.count
        return colors[index]
    }
    
    private func categoryIcon(for categoryName: String) -> String {
        switch categoryName.lowercased() {
        case "dairy": return "drop.fill"
        case "produce": return "leaf.fill"
        case "meat": return "flame.fill"
        case "beverages": return "cup.and.saucer.fill"
        case "bakery": return "birthday.cake.fill"
        case "frozen": return "snowflake"
        case "pantry": return "shippingbox.fill"
        case "snacks": return "popcorn.fill"
        case "personal care": return "heart.fill"
        case "cleaning": return "sparkles"
        case "medicine": return "pills.fill"
        case "vitamins": return "leaf.circle.fill"
        case "first aid": return "bandage.fill"
        case "beauty": return "paintbrush.fill"
        case "tools": return "hammer.fill"
        case "hardware": return "wrench.and.screwdriver.fill"
        case "paint": return "paintpalette.fill"
        case "electrical": return "bolt.fill"
        case "plumbing": return "drop.triangle.fill"
        case "garden": return "tree.fill"
        default: return "tag.fill"
        }
    }
    
    private func toggleCategory(_ category: Category) {
        if let index = selectedCategories.firstIndex(of: category.id) {
            selectedCategories.remove(at: index)
        } else {
            selectedCategories.append(category.id)
        }
    }
}

#Preview {
    CategorySelectorView(
        availableCategories: Category.defaultCategories,
        selectedCategories: .constant([])
    )
}
