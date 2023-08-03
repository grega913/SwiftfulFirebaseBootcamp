//
//  AuthenticationView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by gs on 26/07/2023.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift






@MainActor
final class AuthenticationViewModel: ObservableObject {
    

    
    func signInGoogle() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
      
        try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
    }
    
    
    func signInApple() async throws {
        //startSignInWithAppleFlow()
        
        let helper = SignInAppleHelper()
        let tokens = try await helper.startSignInWithAppleFlow()
        try await AuthenticationManager.shared.signInWithApple(tokens: tokens)
        
    }
    
    
    func signInAnonymous() async throws {
       try await AuthenticationManager.shared.signInAnonymous()
    }


}






struct AuthenticationView: View {
    
    
    @StateObject private var viewModel = AuthenticationViewModel()
    
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack {
            
  
            Button(action: {
                Task {
                    do {
                        try await viewModel.signInAnonymous()
                        showSignInView = false
                    } catch {
                        print(error)
                    }
                }
            }, label: {
                Text("Sign In Anonymously")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .cornerRadius(10
                    )
                
            })
   

            
            NavigationLink {
                SignInEmailView(showSignInView: $showSignInView)
            } label: {
                Text("Sign In With Email")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10
                    )
                
            }
            // Google Sign In Btn
            GoogleSignInButton(viewModel:GoogleSignInButtonViewModel(style: .wide, state: .normal)
            ) {
                Task {
                    do {
                        try await viewModel.signInGoogle()
                        showSignInView = false
                    } catch {
                        print(error)
                    }
                }
            }
            .frame(height: 55)
            
            
            // Apple SignInBtn
            
            Button(action: {
                Task {
                    do {
                        try await viewModel.signInApple()
                        showSignInView = false
                    } catch {
                        print(error)
                    }
                }
            }, label: {
                SignINWithAppleButtonViewrepresentative(type: .default, style: .black)
                    .allowsTightening(false)
                    
            })
            .frame(height:55)

            

            
            
            
            
            Spacer()
        }
        .padding()
        .navigationTitle("Sign In")
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AuthenticationView(showSignInView: .constant(false))
        }
        
    }
}
