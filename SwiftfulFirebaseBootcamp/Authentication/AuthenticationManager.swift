//
//  AuthenticationManager.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by gs on 26/07/2023.
//

import Foundation
import FirebaseAuth


struct AuthDataResultModel {
        let uid: String
        let email: String?
        let photoUrl: String?
        let isAnonymous: Bool
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
        self.isAnonymous = user.isAnonymous
    }
}


enum AuthProviderOption: String {
    case email = "password"
    case google = "google.com"
    case apple = "apple.com"
}


final class AuthenticationManager {
    
    static let shared = AuthenticationManager()
    private init () {
    }
    
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        print("func am.getAuthenticatedUser")
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user: user)
    }
    
    
    // google.com
    // password
    
    func getProviders()  throws  -> [AuthProviderOption] {
        guard let providerData = Auth.auth().currentUser?.providerData else {
            throw URLError(.badServerResponse)
        }
        
        
        var providers: [AuthProviderOption] = []
        
        
        for provider in providerData {
            print(provider.providerID)
            if  let option = AuthProviderOption(rawValue: provider.providerID) {
                providers.append(option)
            } else {
                assertionFailure("Provider option not found: \(provider.providerID)")
            }
        }
        return providers
    }
    

    
    func signOut() throws {
        print("func am.signOut")
        try Auth.auth().signOut()
    }
    
    
    
    func delete() async throws {
        guard let  user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        
        try await user.delete()
    }
    
    
    
    
    

}

//MARK: SIGN IN EMAIL

extension AuthenticationManager {
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        print("func am.createUser")
        let authDataResult =  try await  Auth.auth().createUser(withEmail: email, password: password)
        print("authDataResult in func am.createUser: \(authDataResult.user.uid)")
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    
    @discardableResult
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        print("func am.signInUser")
        let authDataResult = try await  Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    
    func resetPassword(email: String) async throws {
        print("func am.resetPassword")
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    
    func updatePassword(password: String) async throws {
        print("func am.updatePassword")
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        try await user.updatePassword(to: password)
    }
    
    func updateEmail(email: String) async throws {
        print("func am.updateEmail")
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        try await user.updateEmail(to: email)
    }
}


// MARK: SIGN IN SSO

extension AuthenticationManager {
    
    @discardableResult
    func signInWithGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel {
        print("func am signInWithGoogle . . should return AuthDataResultModel")
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        print(credential.description)
        return try await signIn(credential: credential)
        
    }
    
    @discardableResult
    func signInWithApple(tokens: SignInWithAppleResult) async throws -> AuthDataResultModel {
        print("func am signInWithApple . . should return AuthDataResultModel")
        //let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        
        let credential = OAuthProvider.credential(
            withProviderID: AuthProviderOption.apple.rawValue,
            idToken: tokens.token,
            rawNonce: tokens.nonce)
        
        print(credential)
        return try await signIn(credential: credential)
        
    }
    
    
    func signIn(credential: AuthCredential) async throws -> AuthDataResultModel {
        print("func am signIn")
        let authDataResult = try await Auth.auth().signIn(with: credential)
        print(authDataResult.user.email)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    
    
}

// MARK: SIGN IN ANONYMOUS

extension AuthenticationManager {
    
    @discardableResult
    func signInAnonymous () async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signInAnonymously()
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func linkEmail(email: String, password: String) async throws -> AuthDataResultModel {
        let credential = EmailAuthProvider.credential(withEmail: email, link: password)
        
        return try await linkCredential(credential: credential)
        
    }
    
    func linkApple(tokens: SignInWithAppleResult) async throws -> AuthDataResultModel {
        let credential = OAuthProvider.credential(withProviderID: AuthProviderOption.apple.rawValue, idToken: tokens.token, rawNonce: tokens.nonce)
        
        return try await linkCredential(credential: credential)
        
    }
    
    
    func linkGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        
        return try await linkCredential(credential: credential)
        
    }

    
    
    
    private func linkCredential(credential: AuthCredential) async throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        
        let authDataResult = try await user.link(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
}
