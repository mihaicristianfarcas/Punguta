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
    @State private var isSearching = false
    
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
                .onTapGesture { coordinate in
                    // Note: Map tap to set location requires additional implementation
                }
                
                // Search overlay
                VStack {
                    // Search bar
                    HStack(spacing: 12) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.secondary)
                            
                            TextField("Search for a place", text: $searchText)
                                .textFieldStyle(.plain)
                                .onSubmit {
                                    searchLocation()
                                }
                            
                            if !searchText.isEmpty {
                                Button(action: { searchText = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(12)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                        
                        Button(action: { dismiss() }) {
                            Text("Cancel")
                                .fontWeight(.medium)
                        }
                    }
                    .padding()
                    
                    // Search results
                    if isSearching && !searchResults.isEmpty {
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(searchResults, id: \.self) { item in
                                    Button(action: { selectLocation(item) }) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.name ?? "Unknown")
                                                .font(.headline)
                                                .foregroundStyle(.primary)
                                            
                                            if let address = item.placemark.title {
                                                Text(address)
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                                    .lineLimit(2)
                                            }
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                        .background(Color(.systemBackground))
                                    }
                                    
                                    Divider()
                                }
                            }
                        }
                        .frame(maxHeight: 300)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    // Confirm button
                    if selectedCoordinate != nil {
                        VStack(spacing: 12) {
                            if !address.isEmpty {
                                Text(address)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal)
                                    .multilineTextAlignment(.center)
                            }
                            
                            Button(action: { dismiss() }) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Confirm Location")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.gradient)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: -2)
                        .padding()
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func searchLocation() {
        isSearching = true
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        
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
            
            searchResults = response.mapItems
        }
    }
    
    private func selectLocation(_ item: MKMapItem) {
        selectedCoordinate = item.placemark.coordinate
        address = [item.name, item.placemark.title]
            .compactMap { $0 }
            .joined(separator: ", ")
        
        mapPosition = .region(MKCoordinateRegion(
            center: item.placemark.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
        
        searchText = ""
        isSearching = false
        searchResults = []
    }
}
