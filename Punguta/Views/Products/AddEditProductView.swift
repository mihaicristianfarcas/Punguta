//
//  AddEditProductView.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 21.10.2025.
//

import SwiftUI

// MARK: - Add Edit Product View

/// Form view for creating or editing products
///
/// **Features**:
/// - Create new products or edit existing ones
/// - Auto-categorization based on product name
/// - Auto-unit suggestion based on category
/// - Live preview of product
/// - Form validation with helpful error messages
struct AddEditProductView: View {
    
    // MARK: Environment
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: Properties
    
    /// View model managing products
    @ObservedObject var viewModel: ProductViewModel
    
    /// Product being edited (nil for new product)
    let productToEdit: Product?
    
    /// Available categories for selection
    let categories: [Category]
    
    // MARK: Form State
    
    /// Product name input
    @State private var name: String
    
    /// Selected category ID
    @State private var selectedCategoryId: UUID
    
    /// Amount input (as string for TextField)
    @State private var amount: String
    
    /// Selected unit of measurement
    @State private var selectedUnit: String
    
    /// Common units available for selection
    private let commonUnits = ["kg", "g", "L", "mL", "pcs", "pack", "box", "bottle", "can"]
    
    // MARK: Validation State
    
    /// Shows validation error alert
    @State private var showingValidationAlert = false
    
    /// Validation error message
    @State private var validationMessage = ""
    
    // MARK: Computed Properties
    
    /// Validates form input
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !amount.trimmingCharacters(in: .whitespaces).isEmpty &&
        Double(amount) != nil &&
        Double(amount)! > 0
    }
    
    // MARK: Initializer
    
    init(viewModel: ProductViewModel, categories: [Category], productToEdit: Product? = nil) {
        self.viewModel = viewModel
        self.productToEdit = productToEdit
        self.categories = categories
        
        // Initialize state from existing product or defaults
        if let product = productToEdit {
            _name = State(initialValue: product.name)
            _selectedCategoryId = State(initialValue: product.categoryId)
            _amount = State(initialValue: String(product.quantity.amount))
            _selectedUnit = State(initialValue: product.quantity.unit)
        } else {
            _name = State(initialValue: "")
            _selectedCategoryId = State(initialValue: categories.first?.id ?? UUID())
            _amount = State(initialValue: "")
            _selectedUnit = State(initialValue: "pcs")
        }
    }
    
    // MARK: Body
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: Product Name Section
                // Main product name input with auto-categorization trigger
                Section {
                    TextField("Product Name", text: $name)
                        .autocorrectionDisabled()
                        .onChange(of: name) { oldValue, newValue in
                            autoSuggestCategory()
                        }
                } header: {
                    Text("Product Details")
                } footer: {
                    // Show hint about auto-categorization for new products only
                    if productToEdit == nil {
                        Text("Category will be auto-suggested based on product name")
                            .font(.caption)
                    }
                }
                
                // MARK: Category Selection Section
                // Dropdown picker showing all available categories with icons
                Section("Category") {
                    Picker("Select Category", selection: $selectedCategoryId) {
                        ForEach(categories) { category in
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundStyle(category.visualColor)
                                Text(category.name)
                            }
                            .tag(category.id)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // MARK: Quantity Section
                // Amount input with unit selector (e.g., "2.5 kg")
                Section("Quantity") {
                    HStack {
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                            .frame(maxWidth: 100)
                        
                        Picker("Unit", selection: $selectedUnit) {
                            ForEach(commonUnits, id: \.self) { unit in
                                Text(unit).tag(unit)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: 120)
                    }
                }
                
                // MARK: Preview Section
                // Live preview of how the product will appear in lists
                if isFormValid {
                    Section("Preview") {
                        HStack {
                            // Category icon
                            if let category = categories.first(where: { $0.id == selectedCategoryId }) {
                                Image(systemName: category.icon)
                                    .foregroundStyle(category.visualColor)
                                    .font(.title2)
                            }
                            
                            // Product name and quantity
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                                Text(name)
                                    .font(.headline)
                                
                                if let amountValue = Double(amount) {
                                    Text("\(formatAmount(amountValue)) \(selectedUnit)")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, AppTheme.Spacing.sm)
                    }
                }
            }
            .navigationTitle(productToEdit == nil ? "New Product" : "Edit Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Cancel button
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                // Save/Create button (disabled when form is invalid)
                ToolbarItem(placement: .confirmationAction) {
                    Button(productToEdit == nil ? "Create" : "Save") {
                        saveProduct()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isFormValid)
                }
            }
            // Show validation errors in an alert
            .alert("Validation Error", isPresented: $showingValidationAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(validationMessage)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Automatically suggests a category and default unit based on product name
    /// Only runs for new products (not when editing existing products)
    /// Uses the ViewModel's smart categorization algorithm
    private func autoSuggestCategory() {
        // Skip auto-suggestion when editing existing products
        guard productToEdit == nil else { return }
        
        // Use ViewModel to suggest category based on product name
        if let suggestedCategoryId = viewModel.suggestCategory(for: name, categories: categories) {
            selectedCategoryId = suggestedCategoryId
            
            // Also auto-suggest the category's default unit if available
            // For example: "Milk" → Dairy → "L" (liters)
            if let category = categories.first(where: { $0.id == suggestedCategoryId }),
               let defaultUnit = category.defaultUnit {
                selectedUnit = defaultUnit
            }
        }
    }
    
    /// Validates and saves the product (either creating new or updating existing)
    /// Performs validation checks before calling ViewModel methods
    private func saveProduct() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        
        // Validation: Name must not be empty
        guard !trimmedName.isEmpty else {
            validationMessage = "Product name cannot be empty"
            showingValidationAlert = true
            return
        }
        
        // Validation: Amount must be a valid positive number
        guard let amountValue = Double(amount), amountValue > 0 else {
            validationMessage = "Please enter a valid amount greater than 0"
            showingValidationAlert = true
            return
        }
        
        // Create quantity model
        let quantity = ProductQuantity(amount: amountValue, unit: selectedUnit)
        
        if let existingProduct = productToEdit {
            // Update existing product
            var updatedProduct = existingProduct
            updatedProduct.name = trimmedName
            updatedProduct.categoryId = selectedCategoryId
            updatedProduct.quantity = quantity
            updatedProduct.updatedAt = Date()
            
            viewModel.updateProduct(updatedProduct)
        } else {
            // Create new product
            viewModel.createProduct(
                name: trimmedName,
                categoryId: selectedCategoryId,
                quantity: quantity
            )
        }
        
        // Close the sheet
        dismiss()
    }
    
    /// Formats a decimal amount for display
    /// Removes unnecessary decimal places (e.g., "2.0" → "2", "2.5" → "2.5")
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
}

// MARK: - Preview
#Preview {
    AddEditProductView(
        viewModel: ProductViewModel(),
        categories: Category.defaultCategories
    )
}
