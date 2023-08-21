//
//  TabbarView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by gs on 21/08/2023.
//

import SwiftUI

struct TabbarView: View {
    
    @Binding var showSignInView: Bool
    
    var body: some View {
        TabView {
            
            NavigationStack {
                ProductsView()
            }
            .tabItem {
                    Image(systemName: "cart")
                    Text("Products")
                }
            
            NavigationStack {
                FavoriteView()
            }
            .tabItem {
                Image(systemName: "star.fill")
                Text("Favorites")
            }
            
            NavigationStack {
                ProfileView(showSignInView: $showSignInView)
            }
            .tabItem {
                Image(systemName: "person")
                Text("Profile")
            }
           
        }
        
    }
}

struct TabbarView_Previews: PreviewProvider {
    static var previews: some View {
        TabbarView(showSignInView: .constant(false))
    }
}
