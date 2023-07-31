//
//  SignInEmailView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by gs on 26/07/2023.
//

import SwiftUI

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

       try await AuthenticationManager.shared.createUser(email: email, password: password)

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

struct SignInEmailView: View {
    
    @StateObject private var viewModel = SignInEmailViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack {
            
            TextField("Email . . .", text: $viewModel.email)
                .padding()
                .background(Color.gray.opacity(0.4)
                .cornerRadius(10))
            
            SecureField("Password . . .", text: $viewModel.password)
                .padding()
                .background(Color.gray.opacity(0.4)
                .cornerRadius(10))
            
            Button {
                Task {
                    do {
                        try await viewModel.signUp()
                        showSignInView = false
                        return
                    } catch {
                        print(error)
                    }
                    //
                    print("now we'll try to sign in")
                    do {
                        try await viewModel.signIn()
                        showSignInView = false
                        return
                    } catch {
                        print(error)
                    }
                    
                    
                }
            } label: {
                Text("Sign In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }

            
            Spacer()
        }
        .padding()
        .navigationTitle("Sign In With Email")
    }
}

struct SignInEmailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SignInEmailView(showSignInView: .constant(false))
        }
        
    }
}
