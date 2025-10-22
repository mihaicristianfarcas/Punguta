//
//  Category+Visual.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 21.10.2025.
//

import SwiftUI

/// Visual styling extensions for Category
/// Provides colors and icons for UI representation
extension Category {
    /// Realistic color representing the category
    var visualColor: Color {
        switch name.lowercased() {
        case "dairy": return Color(red: 0.95, green: 0.95, blue: 0.9) // Off-white/cream
        case "produce": return Color(red: 0.2, green: 0.7, blue: 0.3) // Fresh green
        case "meat": return Color(red: 0.8, green: 0.2, blue: 0.2) // Red/meat color
        case "beverages": return Color(red: 0.2, green: 0.5, blue: 0.9) // Blue
        case "bakery": return Color(red: 0.85, green: 0.65, blue: 0.4) // Wheat/brown
        case "frozen": return Color(red: 0.6, green: 0.8, blue: 0.95) // Ice blue
        case "pantry": return Color(red: 0.7, green: 0.5, blue: 0.3) // Brown
        case "snacks": return Color(red: 0.95, green: 0.7, blue: 0.2) // Golden/yellow
        case "personal care": return Color(red: 0.7, green: 0.4, blue: 0.8) // Purple
        case "cleaning": return Color(red: 0.3, green: 0.8, blue: 0.9) // Clean blue
        case "medicine": return Color(red: 0.9, green: 0.3, blue: 0.3) // Medical red
        case "vitamins": return Color(red: 0.4, green: 0.8, blue: 0.4) // Healthy green
        case "first aid": return Color(red: 0.95, green: 0.4, blue: 0.4) // Red cross red
        case "beauty": return Color(red: 0.95, green: 0.6, blue: 0.7) // Pink
        case "tools": return Color(red: 0.5, green: 0.5, blue: 0.5) // Metal gray
        case "hardware": return Color(red: 0.6, green: 0.6, blue: 0.6) // Steel gray
        case "paint": return Color(red: 0.3, green: 0.6, blue: 0.9) // Paint blue
        case "electrical": return Color(red: 0.95, green: 0.8, blue: 0.2) // Electric yellow
        case "plumbing": return Color(red: 0.2, green: 0.4, blue: 0.7) // Water blue
        case "garden": return Color(red: 0.3, green: 0.6, blue: 0.3) // Garden green
        default: return Color(red: 0.6, green: 0.6, blue: 0.7) // Default gray
        }
    }
    
    /// SF Symbol icon representing the category
    var icon: String {
        switch name.lowercased() {
        case "dairy": return "drop.fill"
        case "produce": return "carrot.fill"
        case "meat": return "flame.fill"
        case "beverages": return "waterbottle.fill"
        case "bakery": return "stove.fill"
        case "frozen": return "snowflake"
        case "pantry": return "takeoutbag.and.cup.and.straw.fill"
        case "snacks": return "popcorn.fill"
        case "personal care": return "sparkles"
        case "cleaning": return "wind"
        case "medicine": return "cross.vial.fill"
        case "vitamins": return "pills.circle.fill"
        case "first aid": return "cross.case.fill"
        case "beauty": return "eyebrow"
        case "tools": return "hammer.fill"
        case "hardware": return "wrench.and.screwdriver.fill"
        case "paint": return "paintbrush.fill"
        case "electrical": return "bolt.fill"
        case "plumbing": return "shower.fill"
        case "garden": return "leaf.fill"
        default: return "tag.fill"
        }
    }
}
