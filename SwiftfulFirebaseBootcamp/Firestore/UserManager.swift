//
//  UserManager.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by gs on 11/08/2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine




struct Movie: Codable {
    let id: String
    let title: String
    let isPopular: Bool
}

// lesson 10 -> Codable

struct DBUser: Codable {
    let userId: String
    let isAnonymous:  Bool?
    let email:  String?
    let photoUrl:  String?
    let dateCreated: Date?
    let isPremium: Bool?
    let preferences: [String]?
    let favoriteMovie: Movie?
    
    
    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.isAnonymous = auth.isAnonymous
        self.email = auth.email
        self.photoUrl = auth.photoUrl
        self.dateCreated = Date()
        self.isPremium = false
        self.preferences = nil
        self.favoriteMovie = nil
    }
    
    init (
        userId: String,
        isAnonymous:  Bool? = nil,
        email:  String? = nil,
        photoUrl:  String? = nil,
        dateCreated: Date? = nil,
        isPremium: Bool? = nil,
        preferences: [String]? = nil,
        favoriteMovie: Movie? = nil
    ) {
        self.userId = userId
        self.isAnonymous = isAnonymous
        self.email = email
        self.photoUrl = photoUrl
        self.dateCreated = dateCreated
        self.isPremium = isPremium
        self.preferences = preferences
        self.favoriteMovie = favoriteMovie
    }
    
    /*
    func togglePremiumStatus() -> DBUser {
        
        let currentValue = isPremium ?? false
        
        return DBUser(
            userId: userId,
            isAnonymous: isAnonymous,
            email: email,
            photoUrl: photoUrl,
            dateCreated: dateCreated,
            isPremium: !currentValue)
    }
    */
    
//    mutating func togglePremiumStatus() {
//        let currentValue = isPremium ?? false
//        isPremium = !currentValue
//    }
    
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case isAnonymous = "is_anonymous"
        case email = "email"
        case photoUrl = "photo_url"
        case dateCreated = "date_created"
        case isPremium = "user_isPremium"
        case preferences = "preferences"
        case favoriteMovie = "favorite_movie"
        
    }
    
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.isAnonymous = try container.decodeIfPresent(Bool.self, forKey: .isAnonymous)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.isPremium = try container.decodeIfPresent(Bool.self, forKey: .isPremium)
        self.preferences = try container.decodeIfPresent([String].self, forKey: .preferences)
        self.favoriteMovie = try container.decodeIfPresent(Movie.self, forKey: .favoriteMovie)
    }
    
    // create custom decoder
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.isAnonymous, forKey: .isAnonymous)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.photoUrl, forKey: .photoUrl)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.isPremium, forKey: .isPremium)
        try container.encodeIfPresent(self.preferences, forKey: .preferences)
        try container.encodeIfPresent(self.favoriteMovie, forKey: .favoriteMovie)
    }
    


    
    
    
}


final class UserManager {
    
    
    static let shared = UserManager()
    
    private init () {
        
    }
    
    // codeble preparation
    private let userCollection: CollectionReference = Firestore.firestore().collection("users")
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    
    
    private func userFavoriteProductCollection(userId: String) -> CollectionReference {
        userDocument(userId: userId).collection("favorite_products")
    }
    
    private func userFavoriteProductDocument(userId: String, favoriteProductId: String) -> DocumentReference {
        userFavoriteProductCollection(userId: userId).document(favoriteProductId)
    }
    
    
    
    // encoder  . . takes care of how keys from our model are mapped to firestore keys
    // this works well if everyone is taking this into account
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        //encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
        
    }()
    
    // decoder  . . takes care of how keys from our model are mapped to firestore keys
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        //decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
        
    }()
    
    
    private var userFavoriteProductsListener: ListenerRegistration? = nil
    
    
    func createNewUser(user: DBUser) async throws {
        
        //try userDocument(userId: user.userId).setData(from: user, merge: false, encoder: encoder)
        try userDocument(userId: user.userId).setData(from: user, merge: false)
    }
    
    
    /*
    func createNewUser(auth: AuthDataResultModel) async throws {
        
        var userData: [String: Any] = [
            "user_id" : auth.uid,
            "is_anonymous" : auth.isAnonymous,
            "date_created" : Timestamp()
        ]
        
        if let email = auth.email {
            userData["email"] = email
        }
        if let photoUrl = auth.photoUrl {
            userData["photoUrl"] = photoUrl
        }
        
        //try await Firestore.firestore().collection("users").document(auth.uid).setData(userData, merge: false)
        try await userDocument(userId: auth.uid).setData(userData, merge: false)
    }
     */
    
    
    
    func getUser(userId: String) async throws -> DBUser {
        //try await userDocument(userId: userId).getDocument(as: DBUser.self, decoder: decoder)
        try await userDocument(userId: userId).getDocument(as: DBUser.self)
    }
    
    
    /*
    func getUser(userId: String) async throws -> DBUser {
        print("func UserManager.getUser")
        //let snapshot = try await Firestore.firestore().collection("users").document(userId).getDocument()
        let snapshot = try await userDocument(userId: userId).getDocument()
        
        
        guard let data = snapshot.data(), let userId = data["user_id"] as? String else {
            throw URLError(.badServerResponse)
        }
        
    
        let isAnonymous = data["is_anonymous"] as? Bool
        let email = data["email"] as? String
        let photoUrl = data["photo_url"] as? String
        let dateCreated = data["date_created"] as? Date
        
        return DBUser(userId: userId, isAnonymous: isAnonymous, email: email, photoUrl: photoUrl, dateCreated: dateCreated)
                
    }
    */
    
    // we are setting the data for the whole document
    /*
    func updateUserPremiumStatus(user: DBUser) async throws {
        try userDocument(userId: user.userId).setData(from: user, merge: true)
        
    }
     */
    
    // only updating document or actually just a single key
    func updateUserPremiumStatus(userId: String, isPremium: Bool) async throws {
        
        let data: [String: Any] = [
            //"user_isPremium": isPremium
            DBUser.CodingKeys.isPremium.rawValue: isPremium
        ]
        
        try await userDocument(userId: userId).updateData(data)
        
    }
    
    func addUserPreference(userId: String, preference: String) async throws {
        let data: [String: Any] = [
            //"user_isPremium": isPremium
            //DBUser.CodingKeys.preferences.rawValue: [preference]
            DBUser.CodingKeys.preferences.rawValue : FieldValue.arrayUnion([preference])
        ]
        
        try await userDocument(userId: userId).updateData(data)
        
    }
    
    
    func removeUserPreference(userId: String, preference: String) async throws {
        let data: [String: Any] = [
            //"user_isPremium": isPremium
            //DBUser.CodingKeys.preferences.rawValue: [preference]
            DBUser.CodingKeys.preferences.rawValue : FieldValue.arrayRemove([preference])
        ]
        
        try await userDocument(userId: userId).updateData(data)
        
    }
    
    
    func addFavoriteMovie(userId: String, movie: Movie) async throws {
        
        guard let data = try? encoder.encode(movie) else {
            throw URLError(.badURL)
        }
        
        let dict: [String: Any] = [
            //"user_isPremium": isPremium
            //DBUser.CodingKeys.preferences.rawValue: [preference]
            DBUser.CodingKeys.favoriteMovie.rawValue : data
        ]
        
        try await userDocument(userId: userId).updateData(dict)
        
    }
    
    
    func removeFavoriteMovie(userId: String) async throws {
        let data: [String: Any?] = [
            //"user_isPremium": isPremium
            //DBUser.CodingKeys.preferences.rawValue: [preference]
            DBUser.CodingKeys.favoriteMovie.rawValue : nil
        ]
        
        try await userDocument(userId: userId).updateData(data as [AnyHashable: Any])
        
    }
    
    func addUserFavoriteProduct(userId: String, productId: Int) async throws {
        
        let document = userFavoriteProductCollection(userId: userId).document()
        let documentId = document.documentID
        
//        let data: [String: Any] = [
//            "id": documentId,
//            "product_id": productId,
//            "date_created": Timestamp(),
//        ]
        
        let data: [String: Any] = [
            UserFavoriteProduct.CodingKeys.id.rawValue: documentId,
            UserFavoriteProduct.CodingKeys.productId.rawValue: productId,
            UserFavoriteProduct.CodingKeys.dateCreated.rawValue: Timestamp(),
        ]
        
        
        try await document
            .setData(data, merge: false)
        
    }
    
    func removeUserFavoriteProduct(userId: String, favoriteProductId: String) async throws {
        try await userFavoriteProductDocument(userId: userId, favoriteProductId: favoriteProductId).delete()
    }
    

    func getAllUserFavoriteProducts(userId: String) async throws -> [UserFavoriteProduct] {
        try await userFavoriteProductCollection(userId: userId).getDocuments(as: UserFavoriteProduct.self)
    }
    
    
    
    func removeListenerForAllUserFavoriteProducts() {
        self.userFavoriteProductsListener?.remove()
    }
    
    
    // firebase listeners are not currently in async await, so we are using completion handler
    func addListenerForAllUserFavoriteProducts(userId: String, completion: @escaping (_ products: [UserFavoriteProduct])->()) {
        self.userFavoriteProductsListener =   userFavoriteProductCollection(userId: userId).addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
//            let products: [UserFavoriteProduct] = documents.compactMap { documentSnapshot in
//                return try? documentSnapshot.data(as: UserFavoriteProduct.self)
//            }
            
            //one liner
            let products: [UserFavoriteProduct] = documents.compactMap({ try? $0.data(as: UserFavoriteProduct.self)})
            
            completion(products)
            
            // what changed
            querySnapshot?.documentChanges.forEach { diff in
                if(diff.type == .added) {
                    print("New products: \(diff.document.data())")
                }
                if(diff.type == .modified) {
                    print("Modified products: \(diff.document.data())")
                }
                if(diff.type == .removed) {
                    print("Removed product: \(diff.document.data())")
                }
            }
        }
    }
    
    
    //same as above with using publisher and not completion handler
//    func addListenerForAllUserFavoriteProductsWithPublisher(userId: String) -> AnyPublisher<[UserFavoriteProduct], Error> {
//        let publisher = PassthroughSubject<[UserFavoriteProduct], Error>()
//
//
//
//        self.userFavoriteProductsListener =   userFavoriteProductCollection(userId: userId).addSnapshotListener { querySnapshot, error in
//            guard let documents = querySnapshot?.documents else {
//                print("No documents")
//                return
//            }
//
//            let products: [UserFavoriteProduct] = documents.compactMap({ try? $0.data(as: UserFavoriteProduct.self)})
//
//            //completion(products)
//            publisher.send(products)
//
//
//        }
//        return publisher.eraseToAnyPublisher()
//    }
    
    func addListenerForAllUserFavoriteProductsWithPublisher(userId: String) -> AnyPublisher<[UserFavoriteProduct], Error> {
        let(publisher, listener) = userFavoriteProductCollection(userId: userId)
            .addSnapshotListener(as: UserFavoriteProduct.self)
        
        self.userFavoriteProductsListener = listener
        return publisher
    }
    
    
}



struct UserFavoriteProduct: Codable {
    let id: String
    let productId: Int
    let dateCreated: Date
    
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case productId = "product_id"
        case dateCreated = "date_created"
    }
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.productId, forKey: .productId)
        try container.encode(self.dateCreated, forKey: .dateCreated)
    }
    

    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.productId = try container.decode(Int.self, forKey: .productId)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
    }
}
