//
//  EmptyStateView.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 21.10.2025.
//

import SwiftUI

/// Reusable empty state component for consistent empty state displays
/// Used when lists, stores, or products are empty
struct EmptyStateView: View {
    
    // MARK: - Properties
    
    let icon: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: AppTheme.IconSize.huge))
                .foregroundStyle(AppTheme.Colors.secondaryText)
            
            // Text content
            VStack(spacing: AppTheme.Spacing.md) {
                Text(title)
                    .font(.title2)
                    .fontWeight(AppTheme.FontWeight.bold)
                    .foregroundStyle(AppTheme.Colors.primaryText)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Optional action button
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .fontWeight(AppTheme.FontWeight.semibold)
                        .padding(.horizontal, AppTheme.Spacing.xl)
                        .padding(.vertical, AppTheme.Spacing.md)
                        .background(AppTheme.Colors.primaryAction)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                .padding(.top, AppTheme.Spacing.sm)
            }
        }
        .padding(AppTheme.Spacing.xl)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 40) {
        EmptyStateView(
            icon: "cart",
            title: "No Products",
            message: "Start by adding your first product"
        )
        
        EmptyStateView(
            icon: "storefront",
            title: "No Stores Yet",
            message: "Add your first store to start organizing",
            actionTitle: "Add Store",
            action: { print("Add tapped") }
        )
    }
}
