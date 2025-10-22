//
//  FilterPillView.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 21.10.2025.
//

import SwiftUI

/// Reusable filter pill component
/// Used for category filtering and other selection options
struct FilterPillView: View {
    
    // MARK: - Properties
    
    let title: String
    let icon: String?
    let color: Color?
    let isSelected: Bool
    let action: () -> Void
    
    // MARK: - Initializer
    
    init(
        title: String,
        icon: String? = nil,
        color: Color? = nil,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.color = color
        self.isSelected = isSelected
        self.action = action
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.xs + 2) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(AppTheme.FontWeight.md)
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(pillBackground)
            .foregroundStyle(pillForeground)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(pillBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Computed Properties
    
    private var pillBackground: Color {
        if isSelected {
            return (color ?? AppTheme.Colors.primaryAction).opacity(0.2)
        }
        return Color(.systemGray5)
    }
    
    private var pillForeground: Color {
        if isSelected {
            return color ?? AppTheme.Colors.primaryAction
        }
        return AppTheme.Colors.secondaryText
    }
    
    private var pillBorder: Color {
        if isSelected {
            return color ?? AppTheme.Colors.primaryAction
        }
        return .clear
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: AppTheme.Spacing.md) {
        HStack {
            FilterPillView(
                title: "All",
                isSelected: true,
                action: {}
            )
            
            FilterPillView(
                title: "Dairy",
                icon: "drop.fill",
                color: .blue,
                isSelected: false,
                action: {}
            )
            
            FilterPillView(
                title: "Produce",
                icon: "carrot.fill",
                color: .green,
                isSelected: false,
                action: {}
            )
        }
    }
    .padding()
}
