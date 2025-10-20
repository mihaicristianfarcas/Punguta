//
//  ShoppingList.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 20.10.2025.
//

import Foundation

struct ShoppingList: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var productIds: [UUID] // References to global Product IDs
    let createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        productIds: [UUID] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.productIds = productIds
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    mutating func addProduct(_ productId: UUID) {
        if !productIds.contains(productId) {
            productIds.append(productId)
            updatedAt = Date()
        }
    }
    
    mutating func removeProduct(_ productId: UUID) {
        productIds.removeAll { $0 == productId }
        updatedAt = Date()
    }
}
