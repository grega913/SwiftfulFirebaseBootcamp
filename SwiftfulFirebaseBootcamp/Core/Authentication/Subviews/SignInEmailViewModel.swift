//
//  SignInEmailViewModel.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by gs on 11/08/2023.
//

import Foundation

@MainActor
final class SignInEmailViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    
    func signUp() async throws {
        print("func SignInEmailViewModel.signUp")
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found!")
            return
        }
        
        let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
        try await UserManager.shared.createNewUser(auth: authDataResult)
        
    }
    
    func signIn() async throws {
        print("func SignInEmailViewModel.signIn")
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found!")
            return
        }
        
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
        
    }
    
}
