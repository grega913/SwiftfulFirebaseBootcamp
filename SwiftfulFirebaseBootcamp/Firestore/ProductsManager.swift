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

//    private func getAllProducts() async throws -> [Product] {
//        try await productsCollection
//            .getDocuments(as: Product.self)
//    }
//
//    private func getAllProductsSortedByPrice(descending: Bool) async throws -> [Product] {
//        try await productsCollection
//            .order(by: Product.CodingKeys.price.rawValue, descending: descending)
//            .getDocuments(as: Product.self)
//    }
//
//    private func getAllProductsForCategory(category: String) async throws -> [Product] {
//        try await productsCollection
//            .whereField(Product.CodingKeys.category.rawValue, isEqualTo: category)
//            .getDocuments(as: Product.self)
//    }
//
//    private func getAllProductsByPriceAndCategory(descending: Bool, category: String) async throws -> [Product] {
//        try await productsCollection
//            .whereField(Product.CodingKeys.category.rawValue, isEqualTo: category)
//            .order(by: Product.CodingKeys.price.rawValue, descending: descending)
//            .getDocuments(as: Product.self)
//    }
    
    private func getAllProductsQuery() -> Query {
         productsCollection
            
    }
    
    private func getAllProductsSortedByPriceQuery(descending: Bool)  -> Query {
         productsCollection
            .order(by: Product.CodingKeys.price.rawValue, descending: descending)
            
    }
    
    private func getAllProductsForCategoryQuery(category: String) -> Query {
        productsCollection
            .whereField(Product.CodingKeys.category.rawValue, isEqualTo: category)
            
    }
    
    private func getAllProductsByPriceAndCategoryQuery(descending: Bool, category: String)  -> Query {
         productsCollection
            .whereField(Product.CodingKeys.category.rawValue, isEqualTo: category)
            .order(by: Product.CodingKeys.price.rawValue, descending: descending)
            
    }

    
    func getAllProducts(priceDescending descending: Bool?, forCategory category: String?, count: Int, lastDocument: DocumentSnapshot?)
    async throws -> (products: [Product], lastDocument: DocumentSnapshot?) {
        
        var query: Query = getAllProductsQuery()
        
        
        if let descending, let category {
            query = getAllProductsByPriceAndCategoryQuery(descending: descending, category: category)
        } else if let descending {
            query =  getAllProductsSortedByPriceQuery(descending: descending)
        } else if let category {
            query = getAllProductsForCategoryQuery(category: category)
        }
        
        return try await query
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Product.self)
        
 
        

    }
    
    // using rating to locate last element . . what if there are multiple docs with same rating??
    func getProductsByRating(count: Int, lastRating: Double?) async throws -> [Product] {
        try await productsCollection
            .order(by: Product.CodingKeys.rating.rawValue, descending: true)
            .limit(to: count)
            .start(after: [lastRating ?? 999999])
            .getDocuments(as: Product.self)
    }
    
    func getProductsByRating(count: Int, lastDocument: DocumentSnapshot?) async throws -> ( products: [Product], lastDocument: DocumentSnapshot?)  {
        
        if let lastDocument {
            return try await productsCollection
                .order(by: Product.CodingKeys.rating.rawValue, descending: true)
                .limit(to: count)
                .start(afterDocument: lastDocument)
                .getDocumentsWithSnapshot(as: Product.self)
        } else {
            return try await productsCollection
                .order(by: Product.CodingKeys.rating.rawValue, descending: true)
                .limit(to: count)
                .getDocumentsWithSnapshot(as: Product.self)
        }
    }
    
    func getAllProductsCount() async throws -> Int {
        let snapshot = try await productsCollection.count.getAggregation(source: .server)
        return Int(truncating: snapshot.count)
    }
    
    
 }


extension Query {
    
    
    // we are passing any type where type conforms to decodable
    /*
    func getDocuments<T>(as type: T.Type) async throws -> [T] where T: Decodable{
        
        let snapshot = try await self.getDocuments()
        
        
        return try snapshot.documents.map({ document in
//            let product = try document.data(as: T.self)
//            return product
            try document.data(as: T.self)
        })

        //return products
    }
    */
    
    
    func getDocuments<T>(as type: T.Type) async throws -> [T] where T: Decodable{
        
        try await getDocumentsWithSnapshot(as: type).products
        
        
        //return products
    }
    
    
    
    
    
    
    func getDocumentsWithSnapshot<T>(as type: T.Type) async throws -> (products: [T], lastDocument: DocumentSnapshot?) where T: Decodable{
        
        let snapshot = try await self.getDocuments()
        
        
        let products =  try snapshot.documents.map({ document in
            //            let product = try document.data(as: T.self)
            //            return product
            try document.data(as: T.self)
        })
        
        return (products, snapshot.documents.last)
    }
    
    
    func startOptionally(afterDocument lastDocument: DocumentSnapshot?) -> Query {
        
        guard let lastDocument else {
            return self
        }
        
        return self.start(afterDocument: lastDocument)
        

    }
    
    
    
}