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
    @State private var showingLocationPicker = false
    
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
            ScrollView {
                VStack(spacing: 24) {
                    // Store Icon & Name
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(storeTypeColor.gradient)
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: storeTypeIcon)
                                .font(.system(size: 40, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                        
                        VStack(spacing: 8) {
                            TextField("Store Name", text: $name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .textFieldStyle(.plain)
                            
                            Picker("Type", selection: $selectedType) {
                                ForEach(StoreType.allCases, id: \.self) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .pickerStyle(.segmented)
                            .onChange(of: selectedType) { oldValue, newValue in
                                if !isEditing {
                                    updateDefaultCategories(for: newValue)
                                }
                            }
                        }
                    }
                    .padding(.top, 20)
                    
                    // Location Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundStyle(storeTypeColor)
                            Text("Location")
                                .font(.headline)
                        }
                        
                        Button(action: { showingLocationPicker = true }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    if selectedCoordinate != nil {
                                        Text(address.isEmpty ? "Location Selected" : address)
                                            .font(.subheadline)
                                            .foregroundStyle(.primary)
                                            .multilineTextAlignment(.leading)
                                        
                                        Text("Tap to change location")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    } else {
                                        Text("Choose location")
                                            .font(.subheadline)
                                            .foregroundStyle(storeTypeColor)
                                        
                                        Text("Required")
                                            .font(.caption)
                                            .foregroundStyle(.red)
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal)
                    
                    // Categories Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "tag.fill")
                                .foregroundStyle(storeTypeColor)
                            Text("Categories")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button(action: { showingCategorySelector = true }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Edit")
                                }
                                .font(.subheadline)
                                .foregroundStyle(storeTypeColor)
                            }
                        }
                        
                        if selectedCategories.isEmpty {
                            Text("No categories selected")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            VStack(spacing: 8) {
                                ForEach(Array(selectedCategories.enumerated()), id: \.element) { index, categoryId in
                                    if let category = viewModel.category(for: categoryId) {
                                        HStack {
                                            Text("\(index + 1)")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundStyle(.white)
                                                .frame(width: 24, height: 24)
                                                .background(categoryColor(for: category.name))
                                                .clipShape(Circle())
                                            
                                            Text(category.name)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            
                                            Spacer()
                                            
                                            Image(systemName: "line.3.horizontal")
                                                .foregroundStyle(.secondary)
                                        }
                                        .padding()
                                        .background(Color(.secondarySystemBackground))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                                .onMove(perform: moveCategories)
                                
                                Text("Categories are shown in the order above")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 100)
                }
            }
            .background(Color(.systemGroupedBackground))
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
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showingCategorySelector) {
                CategorySelectorView(
                    availableCategories: viewModel.categories,
                    selectedCategories: $selectedCategories
                )
            }
            .fullScreenCover(isPresented: $showingLocationPicker) {
                LocationPickerView(
                    selectedCoordinate: $selectedCoordinate,
                    address: $address
                )
            }
            .safeAreaInset(edge: .bottom) {
                if isFormValid {
                    Button(action: saveStore) {
                        HStack {
                            Image(systemName: isEditing ? "checkmark.circle.fill" : "plus.circle.fill")
                            Text(isEditing ? "Save Changes" : "Add Store")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(storeTypeColor.gradient)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: storeTypeColor.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding()
                    .background(Color(.systemGroupedBackground))
                }
            }
            .onAppear {
                updateDefaultCategories(for: selectedType)
            }
        }
    }
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        selectedCoordinate != nil &&
        !selectedCategories.isEmpty
    }
    
    private var storeTypeIcon: String {
        switch selectedType {
        case .grocery: return "cart.fill"
        case .pharmacy: return "cross.case.fill"
        case .hardware: return "hammer.fill"
        case .convenience: return "storefront.fill"
        }
    }
    
    private var storeTypeColor: Color {
        switch selectedType {
        case .grocery: return .green
        case .pharmacy: return .red
        case .hardware: return .orange
        case .convenience: return .blue
        }
    }
    
    private func categoryColor(for categoryName: String) -> Color {
        let colors: [Color] = [.purple, .pink, .indigo, .teal, .cyan, .mint]
        let index = abs(categoryName.hashValue) % colors.count
        return colors[index]
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
