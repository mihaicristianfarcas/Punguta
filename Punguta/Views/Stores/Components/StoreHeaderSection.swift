//
//  StoreHeaderSection.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 21.10.2025.
//

import SwiftUI

/// Header section displaying store icon, name input, and type picker
/// Allows users to set the store's basic information
struct StoreHeaderSection: View {
    @Binding var name: String
    @Binding var selectedType: StoreType
    let isEditing: Bool
    let onTypeChange: (StoreType) -> Void
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // Store name text field
            TextField("Store Name", text: $name)
                .font(.title3.weight(.semibold))
                .textFieldStyle(.plain)
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.md)
            
            // Store type picker
            Picker("Type", selection: $selectedType) {
                ForEach(StoreType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedType) { oldValue, newValue in
                onTypeChange(newValue)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
    }
}

// MARK: - StoreType Extensions
extension StoreType {
    /// SF Symbol icon for each store type
    var icon: String {
        switch self {
        case .grocery: return "cart.fill"
        case .pharmacy: return "cross.case.fill"
        case .hardware: return "hammer.fill"
        case .hypermarket: return "storefront.fill"
        }
    }
    
    /// Brand color for each store type
    var color: Color {
        switch self {
        case .grocery: return .green
        case .pharmacy: return .red
        case .hardware: return .orange
        case .hypermarket: return .blue
        }
    }
}
