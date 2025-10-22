//
//  AddEditListView.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 21.10.2025.
//

import SwiftUI

// MARK: - Add Edit List View

/// Form view for creating or editing a shopping list
/// Features:
/// - List name input
/// - Product selection from existing products
/// - Delete products from selection (swipe to delete)
/// - Empty state when no products selected
/// - Form validation (list name required)
struct AddEditListView: View {
    
    // MARK: Environment
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: Properties
    
    /// View model for managing lists
    @ObservedObject var listViewModel: ListViewModel
    
    /// View model for managing products
    @ObservedObject var productViewModel: ProductViewModel
    
    /// If editing, this contains the list to edit
    let listToEdit: ShoppingList?
    
    // MARK: Form State
    
    /// List name input
    @State private var name: String = ""
    
    /// Array of selected product IDs
    @State private var selectedProductIds: [UUID] = []
    
    /// Controls display of product picker sheet
    @State private var showingProductPicker = false
    
    // MARK: Computed Properties
    
    /// True if editing an existing list, false if creating new
    private var isEditing: Bool {
        listToEdit != nil
    }
    
    /// Form is valid when name is not empty after trimming whitespace
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    // MARK: Initializer
    
    init(listViewModel: ListViewModel, productViewModel: ProductViewModel, listToEdit: ShoppingList? = nil) {
        self.listViewModel = listViewModel
        self.productViewModel = productViewModel
        self.listToEdit = listToEdit
        
        // Pre-populate form when editing
        if let list = listToEdit {
            _name = State(initialValue: list.name)
            _selectedProductIds = State(initialValue: list.productIds)
        }
    }
    
    // MARK: Body
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: List Name Section
                Section {
                    TextField("List Name", text: $name)
                        .font(.body)
                } header: {
                    Text("Details")
                }
                
                // MARK: Products Section
                Section {
                    // Empty state or product list
                    if selectedProductIds.isEmpty {
                        // Empty state when no products selected
                        Text("No products added yet")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, AppTheme.Spacing.lg)
                    } else {
                        // List of selected products (swipe to delete)
                        ForEach(selectedProducts) { product in
                            ProductRowView(product: product)
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { index in
                                selectedProductIds.remove(at: index)
                            }
                        }
                    }
                    
                    // Add Products button
                    Button("Add Products") {
                        showingProductPicker = true
                    }
                } header: {
                    Text("Products (\(selectedProductIds.count))")
                }
            }
            .navigationTitle(isEditing ? "Edit List" : "New List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Cancel button
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                // Save/Create button (disabled when invalid)
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Create") {
                        saveList()
                    }
                    .disabled(!isFormValid)
                    .fontWeight(.semibold)
                }
            }
            // Product picker sheet
            .sheet(isPresented: $showingProductPicker) {
                ProductPickerView(
                    selectedProductIds: $selectedProductIds,
                    availableProducts: productViewModel.products
                )
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Resolves product IDs to actual Product objects
    private var selectedProducts: [Product] {
        selectedProductIds.compactMap { id in
            productViewModel.products.first { $0.id == id }
        }
    }
    
    /// Saves the list (creating new or updating existing)
    private func saveList() {
        if let existingList = listToEdit {
            // Update existing list
            var updatedList = existingList
            updatedList.name = name
            updatedList.productIds = selectedProductIds
            updatedList.updatedAt = Date()
            listViewModel.updateList(updatedList)
        } else {
            // Create new list
            listViewModel.createList(name: name, productIds: selectedProductIds)
        }
        dismiss()
    }
}

// MARK: - Product Row View

/// Simple row displaying product name and quantity
/// Used in the selected products list
private struct ProductRowView: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            Text(product.name)
                .font(.body)
            
            Text(product.quantity.displayString)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Product Picker View

/// Modal sheet for selecting products to add to the list
/// Features:
/// - Searchable list of all products
/// - Multi-select with checkmark indicators
/// - Real-time search filtering
private struct ProductPickerView: View {
    @Environment(\.dismiss) private var dismiss
    
    /// Binding to selected product IDs array
    @Binding var selectedProductIds: [UUID]
    
    /// All available products to choose from
    let availableProducts: [Product]
    
    /// Search query text
    @State private var searchText = ""
    
    /// Filters products by name based on search text
    private var filteredProducts: [Product] {
        if searchText.isEmpty {
            return availableProducts
        }
        return availableProducts.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredProducts) { product in
                    Button(action: { toggleProduct(product) }) {
                        HStack(spacing: AppTheme.Spacing.md) {
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                                Text(product.name)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                
                                Text(product.quantity.displayString)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            if selectedProductIds.contains(product.id) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                                    .font(.body)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search products")
            .navigationTitle("Select Products")
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
    
    /// Toggles product selection on/off
    private func toggleProduct(_ product: Product) {
        if let index = selectedProductIds.firstIndex(of: product.id) {
            selectedProductIds.remove(at: index)
        } else {
            selectedProductIds.append(product.id)
        }
    }
}

// MARK: - Preview
#Preview {
    AddEditListView(
        listViewModel: ListViewModel(),
        productViewModel: ProductViewModel()
    )
}
