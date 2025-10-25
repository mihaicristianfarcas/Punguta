//
//  ContentView.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 20.10.2025.
//

import SwiftUI
import SwiftData

// MARK: - Content View

/// Main app container with tab-based navigation
///
/// **Architecture**:
/// - Three main tabs: Stores, Lists, Products
/// - SwiftData ModelContext injected via environment
/// - ViewModels initialized with ModelContext for database operations
/// - Views use @Query for automatic data updates
struct ContentView: View {
    
    // MARK: Environment
    
    /// SwiftData model context for database operations
    @Environment(\.modelContext) private var modelContext
    
    // MARK: State
    
    /// View models initialized with ModelContext
    @State private var productViewModel: ProductViewModel?
    @State private var listViewModel: ListViewModel?
    @State private var storeViewModel: StoreViewModel?
    
    // MARK: Body
    
    var body: some View {
        Group {
            if let productVM = productViewModel,
               let listVM = listViewModel,
               let storeVM = storeViewModel {
                TabView {
                    // MARK: Stores Tab
                    StoresListView(
                        storeViewModel: storeVM,
                        productViewModel: productVM,
                        listViewModel: listVM
                    )
                    .tabItem {
                        Label("Stores", systemImage: "storefront")
                    }
                    
                    // MARK: Lists Tab
                    ListsListView(
                        listViewModel: listVM,
                        productViewModel: productVM
                    )
                    .tabItem {
                        Label("Lists", systemImage: "list.bullet")
                    }
                    
                    // MARK: Products Tab
                    ProductsListView(
                        productViewModel: productVM,
                        listViewModel: listVM
                    )
                    .tabItem {
                        Label("Products", systemImage: "cart")
                    }
                }
                .tint(AppTheme.Colors.primaryAction)
            } else {
                ProgressView("Loading...")
            }
        }
        .onAppear {
            // Initialize view models with ModelContext
            if productViewModel == nil {
                productViewModel = ProductViewModel(modelContext: modelContext)
                listViewModel = ListViewModel(modelContext: modelContext)
                storeViewModel = StoreViewModel(modelContext: modelContext)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .modelContainer(for: [Category.self, Product.self, ShoppingList.self, ShoppingListItem.self, Store.self])
}
