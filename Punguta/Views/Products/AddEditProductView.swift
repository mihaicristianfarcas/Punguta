//
//  AddEditProductView.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 21.10.2025.
//

import SwiftUI
import SwiftData

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
    @Environment(\.modelContext) private var modelContext
    
    // MARK: Queries
    
    /// All categories from SwiftData
    @Query(sort: \Category.name) private var categories: [Category]
    
    // MARK: Properties
    
    /// View model managing products
    @ObservedObject var productViewModel: ProductViewModel
    
    /// Product being edited (nil for new product)
    let productToEdit: Product?
    
    /// Optional completion handler called after creating a new product
    /// Passes the newly created product
    var onProductCreated: ((Product) -> Void)?
    
    // MARK: Form State
    
    /// Product name input
    @State private var name: String
    
    /// Selected category
    @State private var selectedCategory: Category?
    
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
    
    init(productViewModel: ProductViewModel, productToEdit: Product? = nil, onProductCreated: ((Product) -> Void)? = nil) {
        self.productViewModel = productViewModel
        self.productToEdit = productToEdit
        self.onProductCreated = onProductCreated
        
        // Initialize state from existing product or defaults
        if let product = productToEdit {
            _name = State(initialValue: product.name)
            _selectedCategory = State(initialValue: product.category)
            _amount = State(initialValue: String(product.quantity.amount))
            _selectedUnit = State(initialValue: product.quantity.unit)
        } else {
            _name = State(initialValue: "")
            _selectedCategory = State(initialValue: nil)
            _amount = State(initialValue: "")
            _selectedUnit = State(initialValue: "pcs")
        }
    }
    
    // MARK: Body
    
    var body: some View {
        NavigationStack {
            Form {
                // Product Name
                Section {
                    TextField("Product Name", text: $name)
                        .autocorrectionDisabled()
                        .onChange(of: name) { oldValue, newValue in
                            autoSuggestCategory()
                        }
                } header: {
                    Text("Name")
                }
                
                // Category
                Section {
                    Picker("Category", selection: $selectedCategory) {
                        Text("None").tag(nil as Category?)
                        ForEach(categories) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.name)
                            }
                            .tag(category as Category?)
                        }
                    }
                    .pickerStyle(.navigationLink)
                } header: {
                    Text("Category")
                }
                
                // Quantity
                Section {
                    HStack(spacing: AppTheme.Spacing.md) {
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                        
                        Divider()
                        
                        Picker("Unit", selection: $selectedUnit) {
                            ForEach(commonUnits, id: \.self) { unit in
                                Text(unit).tag(unit)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                    }
                } header: {
                    Text("Quantity")
                } footer: {
                    if productToEdit == nil && !name.isEmpty {
                        Text("Tip: Category and unit are automatically suggested based on product name")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(productToEdit == nil ? "New Product" : "Edit Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(productToEdit == nil ? "Create" : "Save") {
                        saveProduct()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isFormValid)
                }
            }
            .alert("Validation Error", isPresented: $showingValidationAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(validationMessage)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Automatically suggests a category and default unit based on product name
    /// Uses the ViewModel's smart categorization algorithm
    /// Continues to work as user types
    private func autoSuggestCategory() {
        // Use ViewModel to suggest category based on product name
        if let suggestedCategory = productViewModel.suggestCategory(for: name, from: categories) {
            // Apply the auto-suggestion
            selectedCategory = suggestedCategory
            
            // Also auto-suggest the category's default unit if available
            // For example: "Milk" → Dairy → "L" (liters)
            if let defaultUnit = suggestedCategory.defaultUnit {
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
            existingProduct.name = trimmedName
            existingProduct.category = selectedCategory
            existingProduct.quantity = quantity
            existingProduct.updatedAt = Date()
            
            try? modelContext.save()
        } else {
            // Create new product
            let newProduct = productViewModel.createProduct(
                name: trimmedName,
                category: selectedCategory,
                quantity: quantity
            )
            
            // Call completion handler with the new product
            onProductCreated?(newProduct)
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
        productViewModel: ProductViewModel(modelContext: ModelContext(try! ModelContainer(for: Product.self, Category.self)))
    )
}
