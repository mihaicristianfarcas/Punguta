//
//  LocationSelectionButton.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 21.10.2025.
//

import SwiftUI
import CoreLocation

/// Button that opens location picker and displays current location status
/// Shows different states: not set (required), or set with address
struct LocationSelectionButton: View {
    @Binding var coordinate: CLLocationCoordinate2D?
    @Binding var address: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppTheme.Spacing.md) {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(coordinate != nil ? "Location" : "Set Location")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    
                    if coordinate != nil {
                        Text(address.isEmpty ? "Tap to change" : address)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    } else {
                        Text("Required")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(AppTheme.Spacing.md)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
    }
}
