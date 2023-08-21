//
//  Query+EXT.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by gs on 21/08/2023.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift

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
    
    
    
    func addSnapshotListener<T>(as type: T.Type) -> (AnyPublisher<[T], Error>, ListenerRegistration) where T : Decodable {
        
        let publisher = PassthroughSubject<[T], Error>()
        
        
        
        let listener =  self.addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            let products: [T] = documents.compactMap({ try? $0.data(as: T.self)})
            
            //completion(products)
            publisher.send(products)
            
            
        }
        return (publisher.eraseToAnyPublisher(), listener)
        
    }
    
    
    
    
    
}

