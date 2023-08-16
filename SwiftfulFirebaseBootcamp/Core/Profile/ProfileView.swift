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
       
    }
    
    func togglePremiumStatus() {
        
        guard let user else { return }
        //guard var user else { return }
        
        let currentValue = user.isPremium ?? false
        
        //user.togglePremiumStatus()
        
        //let currentValue = user.isPremium ?? false
        
        //user.isPremium = !currentValue
        
        
        //let currentValue = user.isPremium ?? false
        
//        let updatedUser = DBUser(
//            userId: user.userId,
//            isAnonymous: user.isAnonymous,
//            email: user.email,
//            photoUrl: user.photoUrl,
//            dateCreated: user.dateCreated,
//            isPremium: !currentValue
//        )
        //let updatedUser = user.togglePremiumStatus()
        
        
        Task {
            //try await UserManager.shared.updateUserPremiumStatus(user: updatedUser)
            //self.user = try await UserManager.shared.getUser(userId: user.userId)
            
            //try await UserManager.shared.updateUserPremiumStatus(user: user)
            //self.user = try await UserManager.shared.getUser(userId: user.userId)
            
            try await UserManager.shared.updateUserPremiumStatus(userId: user.userId, isPremium: !currentValue)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
       
    }
    
    
    func addUserPreference(text: String) {
        guard let user else { return }
        
        Task {
            try await UserManager.shared.addUserPreference(userId:user.userId, preference: text)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }

    }
    
    func removeUserPreference(text: String) {
        guard let user else { return }
        
        Task {
            try await UserManager.shared.removeUserPreference(userId:user.userId, preference: text)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
        
    }
    
    func addFavoriteMovie() {
        guard let user else { return }
        let movie = Movie(id: "1", title: "Avatar2", isPopular: true)
        
        Task {
            try await UserManager.shared.addFavoriteMovie(userId:user.userId, movie: movie)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
        
    }
    
    func removeFavoriteMovie() {
        guard let user else { return }

        
        Task {
            try await UserManager.shared.removeFavoriteMovie(userId: user.userId)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
        
    }
    
    
}


struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    
    let preferenceOptions: [String]  = ["Sports", "Movies", "Books"]
    
    private func preferenceIsSelected(text: String) -> Bool {
        viewModel.user?.preferences?.contains(text) == true
    }
    
    var body: some View {
        List {
            if let user = viewModel.user {
                Text("UserId: \(user.userId)")
                
                if let isAnonymous = user.isAnonymous {
                    Text("Is Anonymous: \(isAnonymous.description.capitalized)")
                }
                
                Button {
                    viewModel.togglePremiumStatus()
                } label: {
                    Text("User is premium: \((user.isPremium ?? false).description.capitalized)")
                }
                
                VStack {
                    HStack {
                        
                        ForEach(preferenceOptions, id:\.self) { string in
                            Button(string) {
                                
                                if preferenceIsSelected(text: string) {
                                    viewModel.removeUserPreference(text: string)
                                } else {
                                    viewModel.addUserPreference(text: string)
                                }
                                
                                
                                
                            }
                            .font(.headline)
                            .buttonStyle(.borderedProminent)
                            .tint(preferenceIsSelected(text: string) ? .green : .red)
                        }
                    }
                }
                
                Text("User preferences: \((user.preferences ?? []).joined(separator: ", "))")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button {
                    if (user.favoriteMovie == nil) {
                        viewModel.addFavoriteMovie()
                    } else {
                        viewModel.removeFavoriteMovie()
                    }
                } label: {
                Text("Favorite Movie: \((user.favoriteMovie?.title ?? ""))")
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
            //ProfileView(showSignInView: .constant(false))
            RootView()
        }
       
    }
}
