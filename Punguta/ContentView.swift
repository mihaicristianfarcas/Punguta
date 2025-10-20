//
//  ContentView.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 20.10.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            StoresListView()
                .tabItem {
                    Label("Stores", systemImage: "storefront")
                }
            
            Text("Lists")
                .tabItem {
                    Label("Lists", systemImage: "list.bullet")
                }
            
            Text("Products")
                .tabItem {
                    Label("Products", systemImage: "cart")
                }
        }
    }
}

#Preview {
    ContentView()
}
