//
//  AddEditStoreView.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 20.10.2025.
//

import SwiftUI
import MapKit
import SwiftData

// MARK: - Add Edit Store View

/// Form view for creating or editing a store
/// Features:
/// - Store name input with type-specific icon preview
/// - Store type picker (Grocery, Pharmacy, Hardware, Hypermarket)
/// - Location picker with MapKit integration
/// - Custom category order management (drag to reorder)
/// - Auto-suggested default categories based on store type
/// - Form validation (name, location, at least one category required)
struct AddEditStoreView: View {
    
    // MARK: Environment
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // MARK: Queries
    
    /// All categories from SwiftData
    @Query(sort: \Category.name) private var categories: [Category]
    
    // MARK: Properties
    
    /// View model managing stores and categories
    @ObservedObject var storeViewModel: StoreViewModel
    
    /// If editing, this contains the store to edit
    let storeToEdit: Store?
    
    // MARK: Form State
    
    /// Store name input
    @State private var name: String = ""
    
    /// Selected store type (affects icon, color, and default categories)
    @State private var selectedType: StoreType = .grocery
    
    /// Array of category IDs in the store's custom order
    @State private var selectedCategories: [UUID] = []
    
    /// Selected location coordinate (from map picker)
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    
    /// Optional address string (reverse geocoded or manually entered)
    @State private var address: String = ""
    
    /// Controls display of the location picker sheet
    @State private var showingLocationPicker = false
    
    /// Controls display of the "Add Category" dialog
    @State private var showingAddCategory = false
    
    // MARK: Computed Properties
    
    /// True if editing an existing store, false if creating new
    private var isEditing: Bool {
        storeToEdit != nil
    }
    
    /// Categories not yet added to the store (for Add Category dialog)
    private var availableCategories: [Category] {
        categories.filter { !selectedCategories.contains($0.id) }
    }
    
    /// Form is valid when name is not empty, location is set, and at least one category is selected
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        selectedCoordinate != nil &&
        !selectedCategories.isEmpty
    }
    
    // MARK: Initializer
    
    init(storeViewModel: StoreViewModel, storeToEdit: Store? = nil) {
        self.storeViewModel = storeViewModel
        self.storeToEdit = storeToEdit
        
        // Pre-populate form when editing
        if let store = storeToEdit {
            _name = State(initialValue: store.name)
            _selectedType = State(initialValue: store.type)
            _selectedCategories = State(initialValue: store.categoryOrder)
            _selectedCoordinate = State(initialValue: store.location.coordinate)
            _address = State(initialValue: store.location.address ?? "")
        }
    }
    
    // MARK: Body
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: Store Details Section
                Section("Store Details") {
                    TextField("Store Name", text: $name)
                    
                    Picker("Type", selection: $selectedType) {
                        ForEach(StoreType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .onChange(of: selectedType) { oldValue, newValue in
                        updateDefaultCategories(for: newValue)
                    }
                }
                
                // MARK: Location Section
                Section("Location") {
                    Button(action: { showingLocationPicker = true }) {
                        HStack {
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                                Text(selectedCoordinate != nil ? "Location Set" : "Set Location")
                                    .foregroundStyle(.primary)
                                
                                if let _ = selectedCoordinate {
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
                    }
                }
                
                // MARK: Categories Section
                Section {
                    if selectedCategories.isEmpty {
                        Text("No categories yet")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, AppTheme.Spacing.sm)
                    } else {
                        ForEach(Array(selectedCategories.enumerated()), id: \.element) { index, categoryId in
                            if let category = categories.first(where: { $0.id == categoryId }) {
                                Text(category.name)
                            }
                        }
                        .onMove(perform: moveCategories)
                        .onDelete(perform: deleteCategories)
                    }
                    
                    Button("Add Category") {
                        showingAddCategory = true
                    }
                    .disabled(availableCategories.isEmpty)
                } header: {
                    Text("Categories (\(selectedCategories.count))")
                }
            }
            .navigationTitle(isEditing ? "Edit Store" : "New Store")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Cancel button
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                // Save/Add button (disabled when invalid)
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") {
                        saveStore()
                    }
                    .disabled(!isFormValid)
                    .fontWeight(.semibold)
                }
            }
            // Enable edit mode for drag-to-reorder in category list
            .environment(\.editMode, .constant(.active))
            // Dialog for adding a category from available options
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
            // Full-screen map picker for location selection
            .fullScreenCover(isPresented: $showingLocationPicker) {
                LocationPickerView(
                    selectedCoordinate: $selectedCoordinate,
                    address: $address
                )
            }
            // Auto-populate default categories when creating new store
            .onAppear {
                if (!isEditing) {
                    updateDefaultCategories(for: selectedType)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Updates selected categories to match defaults for the given store type
    /// Triggered automatically when user changes store type (only for new stores)
    /// Maps default category names to IDs from the ViewModel's category list
    private func updateDefaultCategories(for type: StoreType) {
        let categoryMap = Dictionary(uniqueKeysWithValues: 
            categories.map { ($0.name, $0.id) }
        )
        selectedCategories = type.defaultCategoryNames.compactMap { categoryMap[$0] }
    }
    
    /// Reorders categories when user drags them in the list
    /// Maintains the custom category order that will be saved to the store
    private func moveCategories(from source: IndexSet, to destination: Int) {
        selectedCategories.move(fromOffsets: source, toOffset: destination)
    }
    
    /// Deletes categories from the selected list
    /// Can be triggered by swipe action or delete button
    private func deleteCategories(at offsets: IndexSet) {
        withAnimation(.spring(response: 0.3)) {
            selectedCategories.remove(atOffsets: offsets)
        }
    }
    
    /// Saves the store (creating new or updating existing) and dismisses the view
    /// Validates that coordinate is set before proceeding
    /// Creates StoreLocation from coordinate and optional address
    private func saveStore() {
        guard let coordinate = selectedCoordinate else { return }
        
        // Create location model
        let location = StoreLocation(
            coordinate: coordinate,
            address: address.isEmpty ? nil : address
        )
        
        if let existingStore = storeToEdit {
            // Update existing store
            existingStore.name = name
            existingStore.type = selectedType
            existingStore.location = location
            existingStore.categoryOrder = selectedCategories
            
            try? modelContext.save()
        } else {
            // Create new store
            let newStore = storeViewModel.createStore(
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
    let modelContext = ModelContext(try! ModelContainer(for: Store.self, Category.self))
    return AddEditStoreView(storeViewModel: StoreViewModel(modelContext: modelContext))
        .modelContainer(try! ModelContainer(for: Store.self, Category.self))
}

#Preview("Edit Store") {
    let modelContext = ModelContext(try! ModelContainer(for: Store.self, Category.self))
    let storeViewModel = StoreViewModel(modelContext: modelContext)
    let store = storeViewModel.createStore(
        name: "Sample Store",
        type: .grocery,
        location: StoreLocation(
            coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            address: "123 Main St"
        ),
        categoryOrder: []
    )
    return AddEditStoreView(storeViewModel: storeViewModel, storeToEdit: store)
        .modelContainer(try! ModelContainer(for: Store.self, Category.self))
}
