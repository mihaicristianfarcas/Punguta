//
//  AddEditStoreView.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 20.10.2025.
//

import SwiftUI
import MapKit

/// Form view for creating a new store or editing an existing one
/// Manages store name, type, location, and category order
struct AddEditStoreView: View {
    // MARK: - Environment & Dependencies
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: StoreViewModel
    
    // MARK: - State
    let storeToEdit: Store?
    
    @State private var name: String = ""
    @State private var selectedType: StoreType = .grocery
    @State private var selectedCategories: [UUID] = []
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var address: String = ""
    @State private var showingLocationPicker = false
    @State private var showingAddCategory = false
    
    // MARK: - Computed Properties
    private var isEditing: Bool {
        storeToEdit != nil
    }
    
    private var availableCategories: [Category] {
        viewModel.categories.filter { !selectedCategories.contains($0.id) }
    }
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        selectedCoordinate != nil &&
        !selectedCategories.isEmpty
    }
    
    // MARK: - Initialization
    init(viewModel: StoreViewModel, storeToEdit: Store? = nil) {
        self.viewModel = viewModel
        self.storeToEdit = storeToEdit
        
        // Pre-populate form if editing existing store
        if let store = storeToEdit {
            _name = State(initialValue: store.name)
            _selectedType = State(initialValue: store.type)
            _selectedCategories = State(initialValue: store.categoryOrder)
            _selectedCoordinate = State(initialValue: store.location.coordinate)
            _address = State(initialValue: store.location.address ?? "")
        }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Store header: icon, name, type picker
                    StoreHeaderSection(
                        name: $name,
                        selectedType: $selectedType,
                        isEditing: isEditing,
                        onTypeChange: updateDefaultCategories
                    )
                    
                    // Location selection button
                    LocationSelectionButton(
                        coordinate: $selectedCoordinate,
                        address: $address,
                        onTap: { showingLocationPicker = true }
                    )
                    
                    // Category management section
                    CategoryListSection(
                        selectedCategories: $selectedCategories,
                        categories: viewModel.categories,
                        storeTypeColor: selectedType.color,
                        onAddCategory: { showingAddCategory = true },
                        onMove: moveCategories
                    )
                }
                .padding(.bottom, 20)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color(.systemGroupedBackground))
            .navigationTitle(isEditing ? "Edit Store" : "New Store")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") {
                        saveStore()
                    }
                    .disabled(!isFormValid)
                    .fontWeight(.semibold)
                }
            }
            .environment(\.editMode, .constant(.active))
            .confirmationDialog("Add Category", isPresented: $showingAddCategory) {
                ForEach(availableCategories) { category in
                    Button(category.name) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedCategories.append(category.id)
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Choose a category to add")
            }
            .fullScreenCover(isPresented: $showingLocationPicker) {
                LocationPickerView(
                    selectedCoordinate: $selectedCoordinate,
                    address: $address
                )
            }
            .onAppear {
                updateDefaultCategories(for: selectedType)
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Updates selected categories to match defaults for the given store type
    private func updateDefaultCategories(for type: StoreType) {
        let categoryMap = Dictionary(uniqueKeysWithValues: 
            viewModel.categories.map { ($0.name, $0.id) }
        )
        selectedCategories = type.defaultCategoryNames.compactMap { categoryMap[$0] }
    }
    
    /// Reorders categories when user drags them
    private func moveCategories(from source: IndexSet, to destination: Int) {
        selectedCategories.move(fromOffsets: source, toOffset: destination)
    }
    
    /// Saves the store (creates new or updates existing) and dismisses the view
    private func saveStore() {
        guard let coordinate = selectedCoordinate else { return }
        
        let location = StoreLocation(
            coordinate: coordinate,
            address: address.isEmpty ? nil : address
        )
        
        if let existingStore = storeToEdit {
            // Update existing store
            var updatedStore = existingStore
            updatedStore.name = name
            updatedStore.type = selectedType
            updatedStore.location = location
            updatedStore.categoryOrder = selectedCategories
            viewModel.updateStore(updatedStore)
        } else {
            // Create new store
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

// MARK: - Previews
#Preview("Add Store") {
    AddEditStoreView(viewModel: StoreViewModel())
}

#Preview("Edit Store") {
    let viewModel = StoreViewModel()
    let store = viewModel.stores.first!
    return AddEditStoreView(viewModel: viewModel, storeToEdit: store)
}
