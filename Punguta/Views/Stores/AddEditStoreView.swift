//
//  AddEditStoreView.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 20.10.2025.
//

import SwiftUI
import MapKit

struct AddEditStoreView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: StoreViewModel
    
    let storeToEdit: Store?
    
    @State private var name: String = ""
    @State private var selectedType: StoreType = .grocery
    @State private var selectedCategories: [UUID] = []
    @State private var mapPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 44.4268, longitude: 26.1025),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    ))
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var address: String = ""
    @State private var showingCategorySelector = false
    
    private var isEditing: Bool {
        storeToEdit != nil
    }
    
    init(viewModel: StoreViewModel, storeToEdit: Store? = nil) {
        self.viewModel = viewModel
        self.storeToEdit = storeToEdit
        
        if let store = storeToEdit {
            _name = State(initialValue: store.name)
            _selectedType = State(initialValue: store.type)
            _selectedCategories = State(initialValue: store.categoryOrder)
            _selectedCoordinate = State(initialValue: store.location.coordinate)
            _address = State(initialValue: store.location.address ?? "")
            _mapPosition = State(initialValue: .region(MKCoordinateRegion(
                center: store.location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )))
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Store Information") {
                    TextField("Store Name", text: $name)
                    
                    Picker("Store Type", selection: $selectedType) {
                        ForEach(StoreType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .onChange(of: selectedType) { oldValue, newValue in
                        if !isEditing {
                            // Update default categories when type changes (only for new stores)
                            updateDefaultCategories(for: newValue)
                        }
                    }
                }
                
                Section("Location") {
                    TextField("Address (optional)", text: $address)
                    
                    Map(position: $mapPosition, interactionModes: .all) {
                        if let coordinate = selectedCoordinate {
                            Marker("Store Location", coordinate: coordinate)
                                .tint(.blue)
                        }
                    }
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .onTapGesture { location in
                        // Map tap gesture to set location
                    }
                    
                    Button("Set Current Location") {
                        // TODO: Implement location services
                        let bucharest = CLLocationCoordinate2D(latitude: 44.4268, longitude: 26.1025)
                        selectedCoordinate = bucharest
                        mapPosition = .region(MKCoordinateRegion(
                            center: bucharest,
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        ))
                    }
                }
                
                Section {
                    Button(action: { showingCategorySelector = true }) {
                        HStack {
                            Text("Categories")
                            Spacer()
                            Text("\(selectedCategories.count)")
                                .foregroundStyle(.secondary)
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.tertiary)
                                .font(.caption)
                        }
                    }
                    .foregroundStyle(.primary)
                    
                    if !selectedCategories.isEmpty {
                        ForEach(selectedCategories, id: \.self) { categoryId in
                            if let category = viewModel.category(for: categoryId) {
                                HStack {
                                    Image(systemName: "line.3.horizontal")
                                        .foregroundStyle(.secondary)
                                    Text(category.name)
                                    Spacer()
                                }
                            }
                        }
                        .onMove(perform: moveCategories)
                        
                        Text("Drag to reorder categories")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    HStack {
                        Text("Category Order")
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Store" : "New Store")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") {
                        saveStore()
                    }
                    .disabled(!isFormValid)
                }
            }
            .sheet(isPresented: $showingCategorySelector) {
                CategorySelectorView(
                    availableCategories: viewModel.categories,
                    selectedCategories: $selectedCategories
                )
            }
            .onAppear {
                if !isEditing && selectedCategories.isEmpty {
                    updateDefaultCategories(for: selectedType)
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        selectedCoordinate != nil &&
        !selectedCategories.isEmpty
    }
    
    private func updateDefaultCategories(for type: StoreType) {
        let categoryMap = Dictionary(uniqueKeysWithValues: viewModel.categories.map { ($0.name, $0.id) })
        selectedCategories = type.defaultCategoryNames.compactMap { categoryMap[$0] }
    }
    
    private func moveCategories(from source: IndexSet, to destination: Int) {
        selectedCategories.move(fromOffsets: source, toOffset: destination)
    }
    
    private func saveStore() {
        guard let coordinate = selectedCoordinate else { return }
        
        let location = StoreLocation(
            coordinate: coordinate,
            address: address.isEmpty ? nil : address
        )
        
        if let existingStore = storeToEdit {
            var updatedStore = existingStore
            updatedStore.name = name
            updatedStore.type = selectedType
            updatedStore.location = location
            updatedStore.categoryOrder = selectedCategories
            viewModel.updateStore(updatedStore)
        } else {
            viewModel.createStore(
                name: name,
                type: selectedType,
                location: location,
                categoryOrder: selectedCategories
            )
        }
        
        dismiss()
    }
}

#Preview("Add Store") {
    AddEditStoreView(viewModel: StoreViewModel())
}

#Preview("Edit Store") {
    let viewModel = StoreViewModel()
    let store = viewModel.stores.first!
    return AddEditStoreView(viewModel: viewModel, storeToEdit: store)
}
