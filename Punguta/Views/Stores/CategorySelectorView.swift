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
                                        .fill(category.visualColor.opacity(0.15))
                                        .frame(width: 50, height: 50)
                                    
                                    Image(systemName: category.icon)
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundStyle(category.visualColor)
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
                                            .fill(category.visualColor.gradient)
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
        availableCategories: [],
        selectedCategories: .constant([])
    )
}
