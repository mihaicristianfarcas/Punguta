//
//  Product.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 20.10.2025.
//

import Foundation

// MARK: - Product Quantity

/// Represents the quantity of a product with amount and unit of measurement
/// Used to track how much of a product is needed
struct ProductQuantity: Codable, Hashable {
    
    // MARK: Properties
    
    /// The numeric amount (e.g., 2.5)
    var amount: Double
    
    /// The unit of measurement (e.g., "kg", "L", "pcs")
    var unit: String
    
    // MARK: Initializer
    
    init(amount: Double, unit: String) {
        self.amount = amount
        self.unit = unit
    }
    
    // MARK: Display
    
    /// Formatted string representation for display (e.g., "2.5 kg")
    var displayString: String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        let amountString = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        return "\(amountString) \(unit)"
    }
}

// MARK: - Product

/// Global product entity shared across all shopping lists
/// 
/// **Design Decision**: Products are global entities, not list-specific
/// - When a product is checked/unchecked, the state is reflected across all lists
/// - This allows tracking what you've already purchased across multiple shopping trips
/// - Multiple lists can reference the same product
struct Product: Identifiable, Codable, Hashable {
    
    // MARK: Properties
    
    /// Unique identifier for the product
    let id: UUID
    
    /// Display name of the product (e.g., "Milk", "Bananas")
    var name: String
    
    /// Reference to the category this product belongs to
    var categoryId: UUID
    
    /// The quantity needed (amount + unit)
    var quantity: ProductQuantity
    
    /// Shared checked state across all lists
    /// When checked in one list, it's checked everywhere
    var isChecked: Bool
    
    /// When the product was first created
    let createdAt: Date
    
    /// Last modification timestamp
    var updatedAt: Date
    
    // MARK: Initializer
    
    init(
        id: UUID = UUID(),
        name: String,
        categoryId: UUID,
        quantity: ProductQuantity,
        isChecked: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.categoryId = categoryId
        self.quantity = quantity
        self.isChecked = isChecked
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: Mutations
    
    /// Toggle the checked state and update timestamp
    mutating func toggleChecked() {
        isChecked.toggle()
        updatedAt = Date()
    }
    
    /// Update the product quantity and timestamp
    /// - Parameter newQuantity: The new quantity to set
    mutating func updateQuantity(_ newQuantity: ProductQuantity) {
        quantity = newQuantity
        updatedAt = Date()
    }
}

// MARK: - Product Suggestion

/// Represents an auto-categorization suggestion for a product
/// Used when creating new products to suggest category and unit
struct ProductSuggestion {
    
    /// The product name being suggested for
    let name: String
    
    /// The suggested category based on keyword matching
    let suggestedCategory: Category
    
    /// The suggested unit of measurement
    let suggestedUnit: String
    
    /// Confidence score (0.0 to 1.0) indicating match quality
    let confidence: Double
}
