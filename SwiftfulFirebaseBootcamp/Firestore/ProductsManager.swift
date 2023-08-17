//
//  ProductsManager.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by gs on 16/08/2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class ProductsManager {
    
    
    static let shared = ProductsManager()
    
    private init () {
        
    }
    
    // codeble preparation
    private let productsCollection = Firestore.firestore().collection("products")
    
    private func productDocument(productId: String) -> DocumentReference {
        productsCollection.document(productId)
    }
    
    func uploadProduct(product: Product) async throws {
        print("func uploadProduct: \(String(describing: product.description))")
        try productDocument(productId: String(product.id)).setData(from: product, merge: false)
    }
    
    func getProduct(productId: String)  async throws -> Product {
        try await productDocument(productId: productId).getDocument(as: Product.self)
    }

   private func getAllProducts() async throws -> [Product] {
        try await productsCollection.getDocuments(as: Product.self)
    }
    
    private func getAllProductsSortedByPrice(descending: Bool) async throws -> [Product] {
        try await productsCollection
            .order(by: Product.CodingKeys.price.rawValue, descending: descending)
            .getDocuments(as: Product.self)
    }
    
    private func getAllProductsForCategory(category: String) async throws -> [Product] {
        try await productsCollection
            .whereField(Product.CodingKeys.category.rawValue, isEqualTo: category)
            .getDocuments(as: Product.self)
    }
    
    private func getAllProductsByPriceAndCategory(descending: Bool, category: String) async throws -> [Product] {
        try await productsCollection
            .whereField(Product.CodingKeys.category.rawValue, isEqualTo: category)
            .order(by: Product.CodingKeys.price.rawValue, descending: descending)
            .getDocuments(as: Product.self)
    }
    
    func getAllProducts(priceDescending descending: Bool?, forCategory category: String?) async throws -> [Product] {
        if let descending, let category {
            return try await getAllProductsByPriceAndCategory(descending: descending, category: category)
        } else if let descending {
            return try await getAllProductsSortedByPrice(descending: descending)
        } else if let category {
            return try await getAllProductsForCategory(category: category)
        }
        
        return try await getAllProducts()
    }
    
    
}


extension Query {
    
    
    // we are passing any type where type conforms to decodable
    func getDocuments<T>(as type: T.Type) async throws -> [T] where T: Decodable{
        
        let snapshot = try await self.getDocuments()
        
        
        return try snapshot.documents.map({ document in
//            let product = try document.data(as: T.self)
//            return product
            try document.data(as: T.self)
        })

        //return products
    }
    
}
