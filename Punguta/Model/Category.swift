//
//  Category.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 20.10.2025.
//

import Foundation

// MARK: - Category

/// Represents a product category for organization and auto-categorization
///
/// **Key Features**:
/// - Keywords enable automatic product categorization
/// - Default units simplify product creation
/// - Visual styling defined in Category+Visual extension
struct Category: Identifiable, Codable, Hashable {
    
    // MARK: Properties
    
    /// Unique identifier for the category
    let id: UUID
    
    /// Display name of the category (e.g., "Dairy", "Produce")
    var name: String
    
    /// Keywords for auto-categorization (stored in lowercase)
    /// When a product name contains a keyword, this category is suggested
    var keywords: [String]
    
    /// Default unit of measurement for products in this category
    /// Example: "kg" for Produce, "L" for Beverages, "pcs" for Bakery
    var defaultUnit: String?
    
    // MARK: Initializer
    
    init(id: UUID = UUID(), name: String, keywords: [String], defaultUnit: String? = nil) {
        self.id = id
        self.name = name
        // Ensure all keywords are lowercase for case-insensitive matching
        self.keywords = keywords.map { $0.lowercased() }
        self.defaultUnit = defaultUnit
    }
}

// MARK: - Default Categories
extension Category {
    static let defaultCategories: [Category] = [
        Category(
            name: "Dairy",
            keywords: ["milk", "cheese", "butter", "yogurt", "cream", "sour cream", "cottage cheese", "mozzarella", "cheddar", "parmesan"],
            defaultUnit: "L"
        ),
        Category(
            name: "Produce",
            keywords: ["apple", "banana", "tomato", "lettuce", "carrot", "onion", "potato", "cucumber", "pepper", "spinach", "orange", "strawberry"],
            defaultUnit: "kg"
        ),
        Category(
            name: "Meat",
            keywords: ["chicken", "beef", "pork", "lamb", "turkey", "sausage", "bacon", "ham", "steak", "ground beef"],
            defaultUnit: "kg"
        ),
        Category(
            name: "Beverages",
            keywords: ["water", "juice", "soda", "coffee", "tea", "beer", "wine", "coke", "sprite", "lemonade"],
            defaultUnit: "L"
        ),
        Category(
            name: "Bakery",
            keywords: ["bread", "bagel", "croissant", "muffin", "cake", "pastry", "baguette", "rolls", "donuts"],
            defaultUnit: "pcs"
        ),
        Category(
            name: "Frozen",
            keywords: ["ice cream", "frozen pizza", "frozen vegetables", "frozen fruits", "popsicle", "frozen meal"],
            defaultUnit: "pcs"
        ),
        Category(
            name: "Pantry",
            keywords: ["pasta", "rice", "flour", "sugar", "salt", "pepper", "oil", "vinegar", "cereal", "beans", "canned"],
            defaultUnit: "kg"
        ),
        Category(
            name: "Snacks",
            keywords: ["chips", "crackers", "cookies", "chocolate", "candy", "popcorn", "nuts", "pretzels"],
            defaultUnit: "pcs"
        ),
        Category(
            name: "Personal Care",
            keywords: ["shampoo", "soap", "toothpaste", "deodorant", "lotion", "tissue", "toilet paper"],
            defaultUnit: "pcs"
        ),
        Category(
            name: "Cleaning",
            keywords: ["detergent", "bleach", "cleaner", "sponge", "trash bags", "dish soap"],
            defaultUnit: "pcs"
        ),
        // Pharmacy categories
        Category(
            name: "Medicine",
            keywords: ["aspirin", "ibuprofen", "cough syrup", "antibiotic", "allergy", "painkiller", "prescription"],
            defaultUnit: "pcs"
        ),
        Category(
            name: "Vitamins",
            keywords: ["vitamin", "supplement", "multivitamin", "calcium", "omega", "probiotic"],
            defaultUnit: "pcs"
        ),
        Category(
            name: "First Aid",
            keywords: ["bandage", "gauze", "band-aid", "antiseptic", "thermometer", "first aid"],
            defaultUnit: "pcs"
        ),
        Category(
            name: "Beauty",
            keywords: ["makeup", "lipstick", "mascara", "foundation", "perfume", "nail polish", "skincare"],
            defaultUnit: "pcs"
        ),
        // Hardware categories
        Category(
            name: "Tools",
            keywords: ["hammer", "screwdriver", "drill", "saw", "wrench", "pliers", "tape measure"],
            defaultUnit: "pcs"
        ),
        Category(
            name: "Hardware",
            keywords: ["screw", "nail", "bolt", "nut", "anchor", "hinge", "lock"],
            defaultUnit: "pcs"
        ),
        Category(
            name: "Paint",
            keywords: ["paint", "primer", "brush", "roller", "spray paint", "stain", "varnish"],
            defaultUnit: "L"
        ),
        Category(
            name: "Electrical",
            keywords: ["wire", "cable", "outlet", "switch", "bulb", "led", "extension cord", "battery"],
            defaultUnit: "pcs"
        ),
        Category(
            name: "Plumbing",
            keywords: ["pipe", "faucet", "valve", "fitting", "drain", "plunger", "sealant"],
            defaultUnit: "pcs"
        ),
        Category(
            name: "Garden",
            keywords: ["soil", "fertilizer", "seeds", "pot", "hose", "rake", "shovel", "gloves"],
            defaultUnit: "pcs"
        )
    ]
    
    /// Get categories by names, useful for initializing store categories
    static func categories(byNames names: [String]) -> [Category] {
        let categoryMap = Dictionary(uniqueKeysWithValues: defaultCategories.map { ($0.name, $0) })
        return names.compactMap { categoryMap[$0] }
    }
}
