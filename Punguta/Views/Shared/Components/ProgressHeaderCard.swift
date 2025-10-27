//
//  ProgressHeaderCard.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 27.10.2025.
//

import SwiftUI

/// Reusable progress header card component
/// Displays statistics and progress for either a shopping list or a store
/// Features:
/// - Total items vs completed items statistics
/// - Visual progress bar with percentage
/// - Optional subtitle text (e.g., "Updated X ago")
/// - Customizable styling
struct ProgressHeaderCard: View {
    
    // MARK: - Properties
    
    let totalItems: Int
    let completedItems: Int
    let progressPercentage: Double
    let subtitle: String?
    
    // MARK: - Initializers
    
    /// Initializer with all parameters
    /// - Parameters:
    ///   - totalItems: Total number of items
    ///   - completedItems: Number of completed/checked items
    ///   - progressPercentage: Progress as a value between 0.0 and 1.0
    ///   - subtitle: Optional subtitle text to display below the progress bar
    init(
        totalItems: Int,
        completedItems: Int,
        progressPercentage: Double,
        subtitle: String? = nil
    ) {
        self.totalItems = totalItems
        self.completedItems = completedItems
        self.progressPercentage = progressPercentage
        self.subtitle = subtitle
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // MARK: Statistics
            HStack(spacing: AppTheme.Spacing.xl) {
                VStack(spacing: AppTheme.Spacing.xs) {
                    Text("\(totalItems)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    Text(totalItems == 1 ? "Item" : "Items")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(height: 40)
                
                VStack(spacing: AppTheme.Spacing.xs) {
                    Text("\(completedItems)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.green)
                    
                    Text("Completed")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            
            // MARK: Progress Bar
            if totalItems > 0 {
                VStack(spacing: AppTheme.Spacing.sm) {
                    HStack {
                        Text("Progress")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(progressPercentage * 100))%")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                    }
                    
                    ProgressBarView(
                        progress: progressPercentage,
                        height: 8,
                        backgroundColor: Color.gray.opacity(0.2),
                        foregroundColor: .green
                    )
                }
            }
            
            // MARK: Subtitle
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.Spacing.lg)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md))
        .padding(.horizontal, AppTheme.Spacing.md)
    }
}

// MARK: - Preview

#Preview("List Progress") {
    ProgressHeaderCard(
        totalItems: 10,
        completedItems: 7,
        progressPercentage: 0.7,
        subtitle: "Updated 5 minutes ago"
    )
}

#Preview("Store Progress") {
    ProgressHeaderCard(
        totalItems: 25,
        completedItems: 15,
        progressPercentage: 0.6
    )
}

#Preview("Empty State") {
    ProgressHeaderCard(
        totalItems: 0,
        completedItems: 0,
        progressPercentage: 0.0
    )
}
