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
            HStack(spacing: 12) {
                // Location status icon
                LocationStatusIcon(isSet: coordinate != nil)
                
                // Location text information
                LocationInfo(
                    isSet: coordinate != nil,
                    address: address
                )
                
                Spacer()
                
                // Chevron indicator
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.horizontal, 35)
    }
}

/// Icon showing location status (set vs required)
private struct LocationStatusIcon: View {
    let isSet: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isSet ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                .frame(width: 44, height: 44)
            Image(systemName: isSet ? "mappin.circle.fill" : "mappin.slash.circle.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(isSet ? .green : .red)
        }
    }
}

/// Text information about location
private struct LocationInfo: View {
    let isSet: Bool
    let address: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(isSet ? "Location Set" : "Set Location")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
            
            if isSet {
                Text(address.isEmpty ? "Tap to change" : address)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            } else {
                Text("Required")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.red)
            }
        }
    }
}
