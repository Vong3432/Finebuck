//
//  AuthorizedViewModel.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 07/08/2022.
//

import Foundation
import AuthenticationServices
import FirebaseAuth

extension SignInView {
    
    @MainActor
    class SignInViewModel: ObservableObject {
        
        var appleSignInService: AppleSignInService?
        
        init(authService: AnyFirebaseAuthService<User>) {
            appleSignInService = AppleSignInService(authService: authService)
        }
        
        deinit {
            debugPrint("DEINIT SignInViewModel")
        }
        
        // MARK: - Apple sign in
        func startAppleSignInProcess(request: ASAuthorizationAppleIDRequest) {
            appleSignInService?.startSignInWithAppleFlow(request: request)
        }
        
        func verifyAppleSignIn(result: Result<ASAuthorization, Error>) {
            Task {
                await appleSignInService?.verifyResult(authorization: result)
            }
        }
        
        // MARK: - Google sign in
        func handleGoogleSignIn() {
            
        }
    }
}
