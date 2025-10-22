//
//  StatCardView.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 21.10.2025.
//

import SwiftUI

/// Reusable stat card component for displaying metrics
/// Shows an icon, value, and label in a consistent format
struct StatCardView: View {
    
    // MARK: - Properties
    
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            // Icon with colored background
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: AppTheme.IconSize.md))
                    .foregroundStyle(color)
            }
            
            // Value
            Text(value)
                .font(.title3)
                .fontWeight(AppTheme.FontWeight.bold)
                .foregroundStyle(AppTheme.Colors.primaryText)
            
            // Label
            Text(label)
                .font(.caption)
                .foregroundStyle(AppTheme.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.md)
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: AppTheme.Spacing.md) {
        StatCardView(
            icon: "cart.fill",
            value: "12",
            label: "Items",
            color: .blue
        )
        
        StatCardView(
            icon: "checkmark.circle.fill",
            value: "8",
            label: "Completed",
            color: .green
        )
    }
    .padding()
    .background(AppTheme.Colors.groupedBackground)
}
