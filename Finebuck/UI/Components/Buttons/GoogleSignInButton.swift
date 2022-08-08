//
//  GoogleSignInButton.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 07/08/2022.
//

import Foundation

import SwiftUI
import GoogleSignIn
import FirebaseAuth
import Firebase

struct GoogleSignInBtnView: UIViewRepresentable {
    // Create Google Sign In configuration object.
    let clientID = FirebaseApp.app()?.options.clientID
    let config: GIDConfiguration
    let style: GIDSignInButtonStyle
    let authService: FirebaseAuthServiceProtocol
    
    init(style: GIDSignInButtonStyle? = .standard, authService: FirebaseAuthServiceProtocol) {
        self.config = GIDConfiguration(clientID: clientID ?? "")
        self.style = style!
        self.authService = authService
    }
    
    func makeUIView(context: Context) -> GIDSignInButton {
        let signInBtn = GIDSignInButton()
        signInBtn.style = style
        signInBtn.addTarget(context.coordinator, action: #selector(context.coordinator.tap), for: .touchUpInside)
        
        return signInBtn
    }
    
    func updateUIView(_ uiView: GIDSignInButton, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        let parent: GoogleSignInBtnView
        
        init(_ parent: GoogleSignInBtnView) {
            self.parent = parent
        }
        
        private func showTextInputPrompt(_ controller: UIViewController, withMessage message: String, completionBlock: @escaping (Bool, String) -> Void) {
            // create the actual alert controller view that will be the pop-up
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            
            alertController.addTextField { (textField) in
                // configure the properties of the text field
                textField.placeholder = ""
                textField.isUserInteractionEnabled = false
            }
            
            
            // add the buttons/actions to the view controller
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
                // this code runs when the user hits the "save" button
                let input = alertController.textFields![0].text ?? ""
                completionBlock(true, input)
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(saveAction)
            
            controller.present(alertController, animated: true)
        }
        
        private func showMessagePrompt(_ controller: UIViewController, _ message: String) {
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            
            // add the buttons/actions to the view controller
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            
            controller.present(alertController, animated: true)
        }
        
        @objc func tap() {
            
            guard let clientID = parent.clientID else { return }
            
            // Create Google Sign In configuration object.
            let config = GIDConfiguration(clientID: clientID)
            let controller = UIApplication.firstKeyWindowForConnectedScenes!.rootViewController!
            
            // Start the sign in flow!
            GIDSignIn.sharedInstance.signIn(with: config, presenting: controller) { user, error in
                
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                
                guard
                    let authentication = user?.authentication,
                    let idToken = authentication.idToken
                else {
                    return
                }
                
                let credential = GoogleAuthProvider.credential(
                    withIDToken: idToken,
                    accessToken: authentication.accessToken
                )
                
                // sign in
                do {
                    try self.parent.authService.login(credential)
                } catch let error {
                    let authError = error as NSError
                    
                    if authError.code == AuthErrorCode.secondFactorRequired.rawValue {
                        // The user is a multi-factor user. Second factor challenge is required.
                        let resolver = authError
                            .userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
                        var displayNameString = ""
                        for tmpFactorInfo in resolver.hints {
                            displayNameString += tmpFactorInfo.displayName ?? ""
                            displayNameString += " "
                        }
                        
                        self.showTextInputPrompt(
                            controller,
                            withMessage: "Select factor to sign in\n\(displayNameString)",
                            completionBlock: { userPressedOK, displayName in
                                var selectedHint: PhoneMultiFactorInfo?
                                for tmpFactorInfo in resolver.hints {
                                    if displayName == tmpFactorInfo.displayName {
                                        selectedHint = tmpFactorInfo as? PhoneMultiFactorInfo
                                    }
                                }
                                PhoneAuthProvider.provider()
                                    .verifyPhoneNumber(with: selectedHint!, uiDelegate: nil,
                                                       multiFactorSession: resolver
                                        .session) { verificationID, error in
                                            if error != nil {
                                                print(
                                                    "Multi factor start sign in failed. Error: \(error.debugDescription)"
                                                )
                                            } else {
                                                self.showTextInputPrompt(
                                                    controller,
                                                    withMessage: "Verification code for \(selectedHint?.displayName ?? "")",
                                                    completionBlock: { userPressedOK, verificationCode in
                                                        let credential: PhoneAuthCredential? = PhoneAuthProvider.provider()
                                                            .credential(withVerificationID: verificationID!,
                                                                        verificationCode: verificationCode)
                                                        let assertion: MultiFactorAssertion? = PhoneMultiFactorGenerator
                                                            .assertion(with: credential!)
                                                        resolver.resolveSignIn(with: assertion!) { authResult, error in
                                                            if error != nil {
                                                                print(
                                                                    "Multi factor finanlize sign in failed. Error: \(error.debugDescription)"
                                                                )
                                                            } else {
                                                                controller.navigationController?.popViewController(animated: true)
                                                            }
                                                        }
                                                    }
                                                )
                                            }
                                        }
                            }
                        )
                    } else {
                        self.showMessagePrompt(controller, error.localizedDescription)
                        return
                    }
                    // ...
                    print("HMM")
                    return
                }
            }
        }
    }
    
}
