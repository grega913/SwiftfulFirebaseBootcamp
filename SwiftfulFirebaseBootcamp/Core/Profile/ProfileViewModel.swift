//
//  ProfileViewModel.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by gs on 22/08/2023.
//

import Foundation
import PhotosUI
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
    
    
    
    func saveProfileImage(item: PhotosPickerItem) {
        
        guard let user else { return }
        
        Task {
            
            guard let data = try await item.loadTransferable(type: Data.self) else { return }
            
            let (path, name) = try await StorageManager.shared.saveImage(data: data, userId: user.userId)
            print("GREAT SUCCESS")
            print(path)
            print(name)
            let url = try await StorageManager.shared.getUrlForImage(path: path)
            try await UserManager.shared.updateUserProfileImagePath(userId: user.userId, path: path, url: url.absoluteString)
        }
    }
    
    func deleteProfileImage() {
        guard let user, let path = user.profileImagePath else { return }
        
        Task {
            try await StorageManager.shared.deleteImage(path: path)
            try await UserManager.shared.updateUserProfileImagePath(userId: user.userId, path: nil, url: nil)
        }
    }
    
    
}
