//
//  AddEditListView.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 21.10.2025.
//

import SwiftUI
import SwiftData

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
    
    /// All products from SwiftData
    @Query(sort: \Product.name) private var allProducts: [Product]
    
    /// All categories from SwiftData
    @Query private var categories: [Category]
    
    /// If editing, this contains the list to edit
    let listToEdit: ShoppingList?
    
    // MARK: Form State
    
    /// List name input
    @State private var name: String = ""
    
    /// Array of selected products
    @State private var selectedProducts: [Product] = []
    
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
            _selectedProducts = State(initialValue: list.products)
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
                    if selectedProducts.isEmpty {
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
                            selectedProducts.remove(atOffsets: indexSet)
                        }
                    }
                    
                    // Add Products button
                    Button("Add Products") {
                        showingProductPicker = true
                    }
                } header: {
                    Text("Products (\(selectedProducts.count))")
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
                    productViewModel: productViewModel,
                    availableProducts: allProducts,
                    categories: categories,
                    selectedProducts: $selectedProducts
                )
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Saves the list (creating new or updating existing)
    private func saveList() {
        if let existingList = listToEdit {
            // Update existing list
            existingList.name = name
            
            // Remove products no longer selected
            if let items = existingList.items {
                for item in items {
                    if let product = item.product, !selectedProducts.contains(where: { $0.id == product.id }) {
                        listViewModel.removeItem(item, from: existingList)
                    }
                }
            }
            
            // Add newly selected products
            for product in selectedProducts {
                if !existingList.products.contains(where: { $0.id == product.id }) {
                    listViewModel.addProduct(product, to: existingList)
                }
            }
            
            listViewModel.updateList(existingList)
        } else {
            // Create new list
            let newList = listViewModel.createList(name: name)
            for product in selectedProducts {
                listViewModel.addProduct(product, to: newList)
            }
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
private struct ProductPickerView: View {
    @Environment(\.dismiss) private var dismiss
    
    let productViewModel: ProductViewModel
    let availableProducts: [Product]
    let categories: [Category]
    
    @Binding var selectedProducts: [Product]
    
    @State private var searchText = ""
    @State private var showingAddProduct = false
    
    private var filteredProducts: [Product] {
        if searchText.isEmpty {
            return availableProducts
        }
        return availableProducts
            .filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    private var selectedProductIds: Set<UUID> {
        Set(selectedProducts.map { $0.id })
    }
    
    var body: some View {
        NavigationStack {
            List {
                if filteredProducts.isEmpty {
                    Section {
                        Text("No products found")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, AppTheme.Spacing.lg)
                    }
                } else {
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
                                        .font(.body.weight(.semibold))
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .searchable(text: $searchText, prompt: "Search products")
            .navigationTitle("Select Products")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Button {
                        showingAddProduct = true
                    } label: {
                        HStack(spacing: AppTheme.Spacing.xs) {
                            Image(systemName: "plus.circle.fill")
                            Text("Create New")
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showingAddProduct) {
                AddEditProductView(
                    productViewModel: productViewModel,
                    onProductCreated: { product in
                        // Automatically select the newly created product
                        selectedProducts.append(product)
                    }
                )
            }
        }
    }
    
    private func toggleProduct(_ product: Product) {
        if let index = selectedProducts.firstIndex(where: { $0.id == product.id }) {
            selectedProducts.remove(at: index)
        } else {
            selectedProducts.append(product)
        }
    }
}

// MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Category.self, Product.self, ShoppingList.self, ShoppingListItem.self, Store.self,
        configurations: config
    )
    let context = ModelContext(container)
    
    AddEditListView(
        listViewModel: ListViewModel(modelContext: context),
        productViewModel: ProductViewModel(modelContext: context)
    )
    .modelContainer(container)
}
