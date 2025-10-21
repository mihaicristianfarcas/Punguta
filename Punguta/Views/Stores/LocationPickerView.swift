//
//  LocationPickerView.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 20.10.2025.
//

import SwiftUI
import MapKit

struct LocationPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCoordinate: CLLocationCoordinate2D?
    @Binding var address: String
    
    @State private var mapPosition: MapCameraPosition
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    
    init(selectedCoordinate: Binding<CLLocationCoordinate2D?>, address: Binding<String>) {
        self._selectedCoordinate = selectedCoordinate
        self._address = address
        
        let initialCoordinate = selectedCoordinate.wrappedValue ?? CLLocationCoordinate2D(latitude: 44.4268, longitude: 26.1025)
        _mapPosition = State(initialValue: .region(MKCoordinateRegion(
            center: initialCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Map
                Map(position: $mapPosition, interactionModes: .all) {
                    if let coordinate = selectedCoordinate {
                        Marker("Store Location", coordinate: coordinate)
                            .tint(.blue)
                    }
                }
                .ignoresSafeArea()
                
                // Search results overlay
                VStack(spacing: 0) {
                    if !searchResults.isEmpty {
                        VStack(spacing: 0) {
                            // Results header
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundStyle(.secondary)
                                    .font(.subheadline)
                                
                                Text("\(searchResults.count) \(searchResults.count == 1 ? "result" : "results")")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.secondary)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color(.systemGroupedBackground))
                            
                            Divider()
                            
                            // Results list
                            ScrollView {
                                LazyVStack(spacing: 10) {
                                    ForEach(searchResults, id: \.self) { item in
                                        LocationResultRow(item: item) {
                                            selectLocation(item)
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                            .background(Color(.systemGroupedBackground))
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 8)
                        .padding(.horizontal, 16)
                        .frame(maxHeight: 450)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    Spacer()
                }
                .padding(.top, 70)
            }
            .searchable(text: $searchText, prompt: "Search for a place")
            .onChange(of: searchText) { oldValue, newValue in
                if !newValue.isEmpty {
                    searchLocation()
                } else {
                    searchResults = []
                }
            }
            .navigationTitle("Select Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .disabled(selectedCoordinate == nil)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func searchLocation() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        
        // Use current location or selected coordinate as search region
        if let coordinate = selectedCoordinate {
            request.region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
            )
        }
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                print("Search error: \(error?.localizedDescription ?? "Unknown error")")
                searchResults = []
                return
            }
            
            withAnimation(.easeInOut(duration: 0.2)) {
                searchResults = response.mapItems
            }
        }
    }
    
    private func selectLocation(_ item: MKMapItem) {
        // Use location instead of deprecated placemark for coordinate
        let location = item.location
        selectedCoordinate = location.coordinate
        
        // Use address property (iOS 26+) or fallback to placemark
        if #available(iOS 26.0, *) {
            if let mkAddress = item.address {
                address = mkAddress.fullAddress
            }
        } else {
            if let placemarkTitle = item.placemark.title {
                address = placemarkTitle
            }
        }
        
        withAnimation {
            mapPosition = .region(MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        }
        
        // Clear search
        searchText = ""
        withAnimation {
            searchResults = []
        }
    }
}

// MARK: - Location Result Row
private struct LocationResultRow: View {
    let item: MKMapItem
    let onSelect: () -> Void
    
    private var addressText: String {
        if #available(iOS 26.0, *) {
            if let mkAddress = item.address {
                return mkAddress.fullAddress
            }
            return "No address available"
        } else {
            return item.placemark.title ?? "No address available"
        }
    }
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 14) {
                    // Location icon with gradient
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [Color.red, Color.red.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    
                    // Location details
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.name ?? "Unknown Location")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        
                        Text(addressText)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer(minLength: 8)
                }
                .padding(16)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.gray.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    LocationPickerView(
        selectedCoordinate: .constant(nil),
        address: .constant("")
    )
}
