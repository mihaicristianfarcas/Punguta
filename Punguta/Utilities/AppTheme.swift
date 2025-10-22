//
//  AppTheme.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 21.10.2025.
//

import SwiftUI

/// Centralized theme configuration for consistent styling across the app
/// Provides spacing, sizing, colors, and typography standards
enum AppTheme {
    
    // MARK: - Spacing
    
    /// Standard spacing values used throughout the app
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }
    
    // MARK: - Corner Radius
    
    /// Standard corner radius values for consistent rounded corners
    enum CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
    }
    
    // MARK: - Icon Sizes
    
    /// Standard icon sizes for consistency
    enum IconSize {
        static let sm: CGFloat = 16
        static let md: CGFloat = 20
        static let lg: CGFloat = 24
        static let xl: CGFloat = 30
        static let xxl: CGFloat = 40
        static let xxxl: CGFloat = 50
        static let huge: CGFloat = 60
    }
    
    // MARK: - Shadow
    
    /// Standard shadow configurations
    enum Shadow {
        static let sm = ShadowStyle(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
        static let md = ShadowStyle(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        static let lg = ShadowStyle(color: .black.opacity(0.1), radius: 12, x: 0, y: 4)
    }
    
    /// Shadow style configuration
    struct ShadowStyle {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
    
    // MARK: - Colors
    
    /// Semantic colors for consistent theming
    enum Colors {
        // MARK: Action Colors
        static let primaryAction = Color.blue
        static let destructive = Color.red
        static let warning = Color.orange
        static let success = Color.green
        
        // MARK: Background Colors
        static let cardBackground = Color(.systemBackground)
        static let groupedBackground = Color(.systemGroupedBackground)
        
        // MARK: Text Colors
        static let primaryText = Color.primary
        static let secondaryText = Color.secondary
        
        // MARK: Category Colors (predefined palette)
        static let categoryColors: [Color] = [
            .blue, .purple, .pink, .indigo, .teal, .cyan,
            .green, .mint, .orange, .yellow, .red, .brown
        ]
    }
    
    // MARK: - Typography
    
    /// Standard font weights
    enum FontWeight {
        static let light = Font.Weight.light
        static let regular = Font.Weight.regular
        static let md = Font.Weight.medium
        static let semibold = Font.Weight.semibold
        static let bold = Font.Weight.bold
    }
    
    // MARK: - Animation
    
    /// Standard animation durations
    enum Animation {
        static let fast: Double = 0.2
        static let standard: Double = 0.3
        static let slow: Double = 0.5
    }
}

// MARK: - View Extensions for Theme

extension View {
    /// Apply standard card styling
    func cardStyle() -> some View {
        self
            .background(AppTheme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md))
            .shadow(
                color: AppTheme.Shadow.sm.color,
                radius: AppTheme.Shadow.sm.radius,
                x: AppTheme.Shadow.sm.x,
                y: AppTheme.Shadow.sm.y
            )
    }
    
    /// Apply standard section padding
    func sectionPadding() -> some View {
        self.padding(AppTheme.Spacing.md)
    }
}
