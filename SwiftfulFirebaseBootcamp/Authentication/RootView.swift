//
//  RootView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by gs on 26/07/2023.
//

import SwiftUI

struct RootView: View {

    @State private var showSignInView: Bool = false

    var body: some View {
        ZStack {
            
            if !showSignInView {
                NavigationStack {
                    SettingsView(showSignInView: $showSignInView)
                }
            }
            

        }
        .onAppear {
            print("onAppear in RootView")
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.showSignInView = authUser == nil
            
           // try? AuthenticationManager.shared.getProvider()
        }
        .fullScreenCover(isPresented: $showSignInView) {
            NavigationStack {
                AuthenticationView(showSignInView: $showSignInView)
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
