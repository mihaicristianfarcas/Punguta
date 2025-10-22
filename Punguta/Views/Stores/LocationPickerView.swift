//
//  LocationPickerView.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 20.10.2025.
//

import SwiftUI
import MapKit

// MARK: - Location Picker View

/// Full-screen map interface for selecting store location
/// Features:
/// - Interactive MapKit map with pan/zoom
/// - Location search with MKLocalSearch
/// - Search results overlay with selectable locations
/// - Marker showing selected location
/// - Address reverse geocoding
/// - Defaults to Bucharest, Romania if no location pre-selected
struct LocationPickerView: View {
    
    // MARK: Environment
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: Bindings
    
    /// Selected coordinate (updated when user picks a location)
    @Binding var selectedCoordinate: CLLocationCoordinate2D?
    
    /// Address string (human-readable location description)
    @Binding var address: String
    
    // MARK: State
    
    /// Map camera position (controls visible region and zoom level)
    @State private var mapPosition: MapCameraPosition
    
    /// Search query text
    @State private var searchText = ""
    
    /// Search results from MKLocalSearch
    @State private var searchResults: [MKMapItem] = []
    
    // MARK: Initializer
    
    /// Initializes the picker with optional pre-selected coordinate
    /// Defaults to Bucharest (44.4268°N, 26.1025°E) if no coordinate provided
    init(selectedCoordinate: Binding<CLLocationCoordinate2D?>, address: Binding<String>) {
        self._selectedCoordinate = selectedCoordinate
        self._address = address
        
        // Use existing coordinate or default to Bucharest
        let initialCoordinate = selectedCoordinate.wrappedValue ?? 
            CLLocationCoordinate2D(latitude: 44.4268, longitude: 26.1025)
        
        // Set initial map region with moderate zoom level
        _mapPosition = State(initialValue: .region(MKCoordinateRegion(
            center: initialCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )))
    }
    
    // MARK: Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: Map Layer
                // Full-screen interactive map with marker
                Map(position: $mapPosition, interactionModes: .all) {
                    if let coordinate = selectedCoordinate {
                        Marker("Store Location", coordinate: coordinate)
                            .tint(.blue)
                    }
                }
                .ignoresSafeArea()
                
                // MARK: Search Results Overlay
                // Animated overlay showing location search results
                VStack(spacing: 0) {
                    if !searchResults.isEmpty {
                        VStack(spacing: 0) {
                            // MARK: Results Header
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
                            .padding(.horizontal, AppTheme.Spacing.lg)
                            .padding(.vertical, AppTheme.Spacing.md)
                            .background(Color(.systemGroupedBackground))
                            
                            Divider()
                            
                            // MARK: Results List
                            // Scrollable list of search results
                            ScrollView {
                                LazyVStack(spacing: AppTheme.Spacing.sm) {
                                    ForEach(searchResults, id: \.self) { item in
                                        LocationResultRow(item: item) {
                                            selectLocation(item)
                                        }
                                    }
                                }
                                .padding(.horizontal, AppTheme.Spacing.md)
                                .padding(.vertical, AppTheme.Spacing.md)
                            }
                            .background(Color(.systemGroupedBackground))
                        }
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg))
                        .shadow(
                            color: .black.opacity(0.15),
                            radius: 20,
                            x: 0,
                            y: 8
                        )
                        .padding(.horizontal, AppTheme.Spacing.md)
                        .frame(maxHeight: 450)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    Spacer()
                }
                .padding(.top, 70)
            }
            // Search bar integrated in navigation bar
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
                // Cancel button
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                // Done button (disabled until location selected)
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
    
    // MARK: - Helper Methods
    
    /// Performs location search using MKLocalSearch
    /// Uses selected coordinate as search region center for better results
    private func searchLocation() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        
        // Bias search results to area around selected coordinate (if any)
        // This improves relevance when user is refining their selection
        if let coordinate = selectedCoordinate {
            request.region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
            )
        }
        
        // Execute search asynchronously
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                print("Search error: \(error?.localizedDescription ?? "Unknown error")")
                searchResults = []
                return
            }
            
            // Update results with animation
            withAnimation(.easeInOut(duration: 0.2)) {
                searchResults = response.mapItems
            }
        }
    }
    
    /// Selects a location from search results
    /// Updates coordinate, address, and map position
    /// Clears search UI after selection
    private func selectLocation(_ item: MKMapItem) {
        // Extract coordinate from MKMapItem
        let location = item.location
        selectedCoordinate = location.coordinate
        
        // Extract address using iOS 26+ API or fallback to legacy placemark
        if #available(iOS 26.0, *) {
            if let mkAddress = item.address {
                address = mkAddress.fullAddress
            }
        } else {
            if let placemarkTitle = item.placemark.title {
                address = placemarkTitle
            }
        }
        
        // Animate map to focus on selected location with tight zoom
        withAnimation {
            mapPosition = .region(MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        }
        
        // Clear search UI
        searchText = ""
        withAnimation {
            searchResults = []
        }
    }
}

// MARK: - Location Result Row

/// Individual search result row in location picker
/// Shows location icon, name, and address with tap action
private struct LocationResultRow: View {
    let item: MKMapItem
    let onSelect: () -> Void
    
    /// Extracts address text from MKMapItem using iOS 26+ API or fallback
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
                HStack(spacing: AppTheme.Spacing.md) {
                    // MARK: Location Icon
                    // Gradient-filled icon representing the location
                    ZStack {
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
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
                    
                    // MARK: Location Details
                    // Name and address text
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
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
                    
                    Spacer(minLength: AppTheme.Spacing.sm)
                }
                .padding(AppTheme.Spacing.md)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
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
