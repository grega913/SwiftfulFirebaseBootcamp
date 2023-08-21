//
//  FavoriteView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by gs on 21/08/2023.
//

import SwiftUI
import Combine



struct FavoriteView: View {
    
    @StateObject private var viewModel = FavoriteViewModel()
    // checker to set to true when we run addListener, since we only want to add it once
    // and not everytime the view renders
    @State private var didAppear: Bool = false
    

    
    var body: some View {
        List {
            ForEach(viewModel.userFavoriteProducts, id: \.id.self) { item in
                ProductCellViewBuilder(productId: String(item.productId))
                    .contextMenu {
                        Button("remove from favorites") {
                            viewModel.removeFromFavorites(favoriteProductId: item.id)
                        }
                    }
            }
        }
        .navigationTitle("Favorites")
        /*
        .onAppear {
            // one time fetch
            // viewModel.getFavorites()
            // adding listener
            print("FavoriteView - onAppear")
            if !didAppear {
                print("didAppear = false")
                viewModel.addListenerForFavorites()
                didAppear = true
            }
        }
         */
        .onfirstAppear {
            viewModel.addListenerForFavorites()
        }
    }
}

struct FavoriteView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            FavoriteView()
        }
       
    }
}




