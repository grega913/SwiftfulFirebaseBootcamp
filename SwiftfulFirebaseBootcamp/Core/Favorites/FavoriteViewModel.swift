//
//  FavoriteViewModel.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by gs on 21/08/2023.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class FavoriteViewModel: ObservableObject {
    
    
    @Published private(set) var userFavoriteProducts: [UserFavoriteProduct] = []
    private var cancellables = Set<AnyCancellable>()
    
    // adding listener for monitoring changes
    func addListenerForFavorites() {
        print("func addListenerForFavorites")
        guard let authDataResult = try? AuthenticationManager.shared.getAuthenticatedUser() else { return }
        
        // this is the version with completion handler
        //        UserManager.shared.addListenerForAllUserFavoriteProducts(userId: authDataResult.uid) { [weak self] products in
        //            self?.userFavoriteProducts = products
        //        }
        
        //this is the version with publisher
        UserManager.shared.addListenerForAllUserFavoriteProductsWithPublisher(userId: authDataResult.uid)
            .sink { completion in
                
            } receiveValue: { [weak self] products in
                self?.userFavoriteProducts = products
                
            }
            .store(in: &cancellables)
        
        
        
    }
    
    
    // getting products from firestore once
    func getFavorites() {
        Task {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            self.userFavoriteProducts = try await UserManager.shared.getAllUserFavoriteProducts(userId: authDataResult.uid)
            
            
            //            var localArray: [(userFavoriteProduct: UserFavoriteProduct, product: Product)] = []
            //
            //            for userFavoritedProduct in userFavoritedProducts {
            //                if let product = try? await ProductsManager.shared.getProduct(productId: String(userFavoritedProduct.productId)) {
            //                    localArray.append((userFavoriteProduct: userFavoritedProduct, product: product))
            //                }
            //            }
            //            self.products = localArray
        }
    }
    
    
    func removeFromFavorites (favoriteProductId: String) {
        Task {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            
            try? await UserManager.shared.removeUserFavoriteProduct(
                userId: authDataResult.uid, favoriteProductId: favoriteProductId)
            
            //getFavorites() / this wan needed before we added listener
        }
    }
    
    
}
