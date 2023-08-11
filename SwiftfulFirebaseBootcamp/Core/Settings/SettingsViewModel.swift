//
//  SettingsViewModel.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by gs on 11/08/2023.
//

import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    
    
    @Published var authProviders: [AuthProviderOption] = []
    @Published var authUser: AuthDataResultModel? = nil
    
    func loadAuthProviders() {
        if let providers = try? AuthenticationManager.shared.getProviders() {
            authProviders = providers
        }
    }
    
    func loadAuthUser() {
        self.authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
    }
    
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func deleteAccount() async throws {
        try await AuthenticationManager.shared.delete()
    }
    
    func resetPassword() async throws {
        print("func settingsViewModel.resetPassword")
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        guard let email = authUser.email else {
            throw URLError(.fileDoesNotExist)
        }
        
        try await  AuthenticationManager.shared.resetPassword(email: email)
    }
    
    func updatePassword() async throws {
        print("func settingsViewModel.updatePassword")
        let password = "Hello123"
        try await AuthenticationManager.shared.updatePassword(password: password)
    }
    
    func updateEmail() async throws {
        print("func settingsViewModel.updateEmail")
        let email = "hello123@gmail.com"
        try await AuthenticationManager.shared.updateEmail(email: email)
    }
    
    func linkGoogleAccount() async throws {
        
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        
        self.authUser =  try await AuthenticationManager.shared.linkGoogle(tokens: tokens)
        
    }
    
    func linkAppleAccount() async throws {
        
        let helper = SignInAppleHelper()
        let tokens = try await helper.startSignInWithAppleFlow()
        
        self.authUser = try await AuthenticationManager.shared.linkApple(tokens: tokens)
        
    }
    
    func linkEmailAccount() async throws {
        let email = "hello123@gmail.com"
        let password = "Hello123!"
        
        
        self.authUser = try await AuthenticationManager.shared.linkEmail(email: email,password: password)
        
    }
    
    
    
}
