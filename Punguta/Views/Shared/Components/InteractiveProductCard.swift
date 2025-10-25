//
//  InteractiveProductCard.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 23.10.2025.
//

import SwiftUI

// MARK: - Interactive Product Card

/// Reusable product card with checkbox functionality
/// Supports two modes:
/// 1. **Direct mode**: Checkbox state and actions passed as closures (for ListDetailView with swipe actions)
/// 2. **Managed mode**: Checkbox state managed via ListViewModel (for StoreDetailView)
struct InteractiveProductCard: View {
    
    // MARK: Properties
    
    let product: Product
    let isChecked: Bool
    let onToggle: () -> Void
    
    // Optional swipe actions (only for ListDetailView)
    var onEdit: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    
    // MARK: Body
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Checkbox
            Button(action: onToggle) {
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isChecked ? .green : .secondary)
            }
            .buttonStyle(.plain)
            
            // Product Info
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(product.name)
                    .font(.body)
                    .fontWeight(AppTheme.FontWeight.semibold)
                    .foregroundStyle(isChecked ? .secondary : .primary)
                    .strikethrough(isChecked, color: .secondary)
                
                Text(product.quantity.displayString)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, AppTheme.Spacing.xs)
        .padding(.horizontal, AppTheme.Spacing.md)
//        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md))
        .contentShape(Rectangle())
        .modifier(SwipeActionsModifier(onEdit: onEdit, onDelete: onDelete))
    }
}

// MARK: - Interactive Product Card (ViewModel Managed)

/// Version of InteractiveProductCard that observes ListViewModel for dynamic state updates
/// Used in StoreDetailView where checkbox state needs to reactively update
struct InteractiveProductCardManaged: View {
    let product: Product
    let listId: UUID
    @ObservedObject var listViewModel: ListViewModel
    
    private var isChecked: Bool {
        listViewModel.isProductChecked(product, in: listId)
    }
    
    var body: some View {
        InteractiveProductCard(
            product: product,
            isChecked: isChecked,
            onToggle: {
                listViewModel.toggleProductChecked(product, in: listId)
            }
        )
    }
}

// MARK: - Swipe Actions Modifier

/// Conditionally applies swipe actions only when callbacks are provided
private struct SwipeActionsModifier: ViewModifier {
    let onEdit: (() -> Void)?
    let onDelete: (() -> Void)?
    
    func body(content: Content) -> some View {
        if let onEdit = onEdit, let onDelete = onDelete {
            content
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(action: onDelete) {
                        Label("Remove", systemImage: "trash")
                    }
                    .tint(.red)
                    
                    Button(action: onEdit) {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.orange)
                }
        } else {
            content
        }
    }
}

// MARK: - Preview

#Preview("Unchecked") {
    let product = Product(
        name: "Milk",
        category: nil,
        quantity: ProductQuantity(amount: 2, unit: "kg")
    )
    
    InteractiveProductCard(
        product: product,
        isChecked: false,
        onToggle: {},
        onEdit: {},
        onDelete: {}
    )
    .padding()
}
