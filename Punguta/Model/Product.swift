//
//  Product.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 20.10.2025.
//

import Foundation

struct ProductQuantity: Codable, Hashable {
    var amount: Double
    var unit: String // "kg", "L", "pcs", etc.
    
    init(amount: Double, unit: String) {
        self.amount = amount
        self.unit = unit
    }
    
    var displayString: String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        let amountString = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        return "\(amountString) \(unit)"
    }
}

/// Global product entity shared across all shopping lists
/// When a product is checked or quantity is modified, changes are reflected across all lists
struct Product: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var categoryId: UUID
    var quantity: ProductQuantity
    var isChecked: Bool // Shared state across all lists
    let createdAt: Date
    var updatedAt: Date
    
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
    
    mutating func toggleChecked() {
        isChecked.toggle()
        updatedAt = Date()
    }
    
    mutating func updateQuantity(_ newQuantity: ProductQuantity) {
        quantity = newQuantity
        updatedAt = Date()
    }
}

// MARK: - Product Suggestion for Auto-Categorization
struct ProductSuggestion {
    let name: String
    let suggestedCategory: Category
    let suggestedUnit: String
    let confidence: Double // 0-1 score for match quality
}
