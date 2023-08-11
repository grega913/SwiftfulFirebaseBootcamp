//
//  ProfileView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by gs on 11/08/2023.
//

import SwiftUI


@MainActor
final class ProfileViewModel: ObservableObject {
    
    
    //@Published private(set) var user: AuthDataResultModel? = nil
    
    // need to get data from users collection (firestore)
    @Published private(set) var user: DBUser? = nil
    
    func loadCurrentUser() async throws {
        print("func ProfileViewModel.loadCurrentUser")
     let authDataResult =  try AuthenticationManager.shared.getAuthenticatedUser()
     self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
        print("self.user: \(self.user)")
    }
    
}


struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        List {
            if let user = viewModel.user {
                Text("UserId: \(user.userId)")
                
                if let isAnonymous = user.isAnonymous {
                    Text("Is Anonymous: \(isAnonymous.description.capitalized)")
                }
                

            }
        }
        .task {
           try?  await viewModel.loadCurrentUser()
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    SettingsView(showSignInView: $showSignInView)
                } label: {
                    Image(systemName: "gear")
                        .font(.headline)
                }
                
            }
        }
        
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfileView(showSignInView: .constant(false))
        }
       
    }
}