//
//  ContentView.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 20.10.2025.
//

import SwiftUI

// MARK: - Content View

/// Main app container with tab-based navigation
///
/// **Architecture**:
/// - Three main tabs: Stores, Lists, Products
/// - ProductViewModel manages all products globally
/// - ListViewModel manages shopping lists and references products
/// - StoresListView manages its own StoreViewModel
/// - Coordination between ListViewModel and ProductViewModel ensures data consistency
struct ContentView: View {
    
    // MARK: Properties
    
    /// Shared view model for products
    /// Ensures product data is consistent across all views
    @StateObject private var productViewModel = ProductViewModel()
    
    /// View model for shopping lists
    /// Manages lists and their relationships with products
    @StateObject private var listViewModel = ListViewModel()
    
    // MARK: Body
    
    var body: some View {
        TabView {
            // MARK: Stores Tab
            StoresListView()
                .tabItem {
                    Label("Stores", systemImage: "storefront")
                }
            
            // MARK: Lists Tab
            ListsView(productViewModel: productViewModel)
                .tabItem {
                    Label("Lists", systemImage: "list.bullet")
                }
                .environmentObject(listViewModel)
            
            // MARK: Products Tab
            ProductsListView(productViewModel: productViewModel, listViewModel: listViewModel)
                .tabItem {
                    Label("Products", systemImage: "cart")
                }
        }
        // Apply consistent tab styling
        .tint(AppTheme.Colors.primaryAction)
        .onAppear {
            // Initialize sample lists with product IDs if needed
            if listViewModel.shoppingLists.count == 2 &&
               listViewModel.shoppingLists[0].productIds.isEmpty &&
               productViewModel.products.count > 0 {
                listViewModel.initializeSampleLists(with: productViewModel.products)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
