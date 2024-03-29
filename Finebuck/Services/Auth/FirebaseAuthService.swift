//
//  AuthService.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 08/05/2022.
//

import Foundation
import FirebaseAuth
import Resolver

/// Like a root auth service class that contain sub-services (e.g.: AppleSignInService, GoogleSignInService, ...)
final class FirebaseAuthService: ObservableObject, FirebaseAuthServiceProtocol {
    
//    static let shared: FirebaseAuthService = FirebaseAuthService()
    let profileRepository = ProfileRepository()
    @Injected private var dataService: AnyFirestoreDBRepository<Budgeting>
    
    private var authenticationStateHandler: AuthStateDidChangeListenerHandle?
    
    @Published var isLoading = false
    var isLoadingPublished: Published<Bool> { _isLoading }
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    
    @Published var user: User? = nil
    var userPublished: Published<User?> { _user }
    var userPublisher: Published<User?>.Publisher { $user }
    
    @Published var errorMsg: String?
    var errorMsgPublished: Published<String?> { _errorMsg }
    var errorMsgPublisher: Published<String?>.Publisher { $errorMsg }
    
    @Published var profile: Profile?
    var profilePublished: Published<Profile?> { _profile }
    var profilePublisher: Published<Profile?>.Publisher { $profile }
    
    init() {
        addListeners()
    }
    
    deinit {
        Auth.auth().removeStateDidChangeListener(authenticationStateHandler!)
    }
    
    internal func addListeners() {
        if let handle = authenticationStateHandler {
            Auth.auth().removeStateDidChangeListener(handle)
        }
        
        authenticationStateHandler = Auth.auth()
            .addStateDidChangeListener { [weak self] _, user in
                if let user = user {
                    // logged in ...
                    
                    // check profile
                    self?.getProfile(for: user)
                } else {
                    // signout
                    
                    // cleanup
                    self?.cleanup()
                }
                self?.user = user
            }
    }
    
    // MARK: - Login with social login
    // Google
    func login(_ credential: AuthCredential) throws {
        // Sign in with Firebase.
        updateLoadingStatus(loading: true)
        updateErrorMsg(msg: nil)
        
        // sign in
        Task {
            try await Auth.auth().signIn(with: credential)
        }
    }
    
    // Apple
    func login(_ credential: OAuthCredential) async throws {
        // Sign in with Firebase.
        do {
            updateLoadingStatus(loading: true)
            updateErrorMsg(msg: nil)
            
            try await Auth.auth().signIn(with: credential)
        } catch let error {
            updateErrorMsg(msg: FirebaseAuthService.handleErr(error).localizedDescription)
        }
    }
    
    // MARK: - Login & Register with email & password
    func login(_ email: String, _ password: String) async throws {
        do {
            updateLoadingStatus(loading: true)
            updateErrorMsg(msg: nil)
            
            try await Auth.auth().signIn(withEmail: email, password: password)

        } catch let error {
            updateErrorMsg(msg: FirebaseAuthService.handleErr(error).localizedDescription)
        }
    }
    
    func register(_ email: String, _ password: String) async throws {
        do {
            updateLoadingStatus(loading: true)
            updateErrorMsg(msg: nil)
            
            try await Auth.auth().createUser(withEmail: email, password: password)
        } catch let error {
            updateErrorMsg(msg: FirebaseAuthService.handleErr(error).localizedDescription)
        }
        
        updateLoadingStatus(loading: false)
    }
    
    // MARK: - Logout
    
    func logout() {
        do {
            updateLoadingStatus(loading: true)
            updateErrorMsg(msg: nil)
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    // MARK: - Cleanup
    func cleanup() {
        dataService.removeListeners()
        dataService.reset()
        profile = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.updateLoadingStatus(loading: false)
        }
    }
}

extension FirebaseAuthService {
    /// Convert Firebase Auth error to AuthError type.
    static func handleErr(_ error: Error) -> AuthError {
        guard let error = error as NSError?,
              let errorCode = AuthErrorCode.Code(rawValue: error.code) else {
            print("there was an error logging in but it could not be matched with a firebase code")
            return .unknown
        }
        
        switch errorCode {
        case .invalidEmail:
            return .invalidEmail
        case .userNotFound:
            fallthrough
        case .wrongPassword:
            return .incorrect
        case .emailAlreadyInUse:
            return .registered
        default:
            return .unknown
        }
    }
    
    private func updateLoadingStatus(loading: Bool) {
        DispatchQueue.main.async {
            self.isLoading = loading
        }
    }
    
    private func updateErrorMsg(msg: String?) {
        DispatchQueue.main.async {
            self.errorMsg = msg
        }
    }
}

// MARK: - Profile
extension FirebaseAuthService {
    private func getProfile(for user: User) {
        Task { @MainActor in
            self.profile = try? await profileRepository.get(user.uid)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.updateLoadingStatus(loading: false)
            }
        }
    }
    
    func saveProfile(name: String) {
        guard let user = self.user else { return }
        Task { @MainActor in        
            let profile = try? await profileRepository.save(user, name: name)
            self.profile = profile
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.updateLoadingStatus(loading: false)
            }
        }
    }
}
