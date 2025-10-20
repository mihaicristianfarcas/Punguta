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
            List {
                ForEach(filteredCategories) { category in
                    Button(action: { toggleCategory(category) }) {
                        HStack {
                            Text(category.name)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            if selectedCategories.contains(category.id) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search categories")
            .navigationTitle("Select Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
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
        availableCategories: Category.defaultCategories,
        selectedCategories: .constant([])
    )
}
