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
        VStack {
            HStack(spacing: 16) {
                // Store type icon circle
                StoreTypeIcon(type: selectedType)
                
                // Store name text field
                TextField("Store Name", text: $name)
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 35)
            .padding(.vertical, 10)
            
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
        .padding(.horizontal, 35)
    }
}

/// Large circular icon representing the store type
private struct StoreTypeIcon: View {
    let type: StoreType
    
    var body: some View {
        ZStack {
            Circle()
                .fill(type.color.gradient)
                .frame(width: 70, height: 70)
            Image(systemName: type.icon)
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(.white)
        }
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
        case .convenience: return "storefront.fill"
        }
    }
    
    /// Brand color for each store type
    var color: Color {
        switch self {
        case .grocery: return .green
        case .pharmacy: return .red
        case .hardware: return .orange
        case .convenience: return .blue
        }
    }
}
