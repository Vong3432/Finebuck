//
//  AuthService.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 11/05/2022.
//

//
//  AuthService.swift
//  Parking Compass
//
//  Created by Vong Nyuksoon on 28/02/2022.
//

import Foundation
import FirebaseAuth
import Combine

enum AuthError: LocalizedError {
    case incorrect, registered, invalidEmail, unknown
    
    var errorDescription: String? {
        switch self {
        case .incorrect:
            return "Incorrect info. Please try again."
        case .registered:
            return "This email is already registered."
        case .unknown:
            return "Something went wrong"
        case .invalidEmail:
            return "Invalid email"
        }
    }
}

protocol AuthServiceProtocol {
    associatedtype UserType
    
    var user: UserType? { get set }
    var userPublished: Published<UserType?> { get }
    var userPublisher: Published<UserType?>.Publisher { get }
    
    var isLoading: Bool { get set }
    var isLoadingPublished: Published<Bool> { get }
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    
    var profile: Profile? { get set }
    var profilePublished: Published<Profile?> { get }
    var profilePublisher: Published<Profile?>.Publisher { get }
    
    var errorMsg: String? { get set }
    var errorMsgPublished: Published<String?> { get }
    var errorMsgPublisher: Published<String?>.Publisher { get }
    
    func addListeners() -> Void
    func saveProfile(name: String) -> Void
}

protocol AuthSocialSignInProtocol: AuthServiceProtocol {
    func login(_ credential: OAuthCredential) async throws -> Void
    func login(_ credential: AuthCredential) throws -> Void
}

protocol AuthEmailPasswordProtocol: AuthServiceProtocol {
    func login(_ email: String, _ password: String) async throws -> Void
    func register(_ email: String, _ password: String) async throws -> Void
    func logout() -> Void
}

protocol FirebaseAuthServiceProtocol: AuthEmailPasswordProtocol, AuthSocialSignInProtocol {
    
}

// MARK: - Type Erasure
class AnyFirebaseAuthService<T>: FirebaseAuthServiceProtocol, ObservableObject {
    typealias UserType = T
    
    @Published var user: T?
    var userPublished: Published<T?> { _user }
    var userPublisher: Published<T?>.Publisher { $user }
    
    @Published var profile: Profile?
    var profilePublished: Published<Profile?> { _profile }
    var profilePublisher: Published<Profile?>.Publisher { $profile }
    
    @Published var isLoading: Bool = false
    var isLoadingPublished: Published<Bool> { _isLoading }
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    
    @Published var errorMsg: String?
    var errorMsgPublished: Published<String?> { _errorMsg }
    var errorMsgPublisher: Published<String?>.Publisher { $errorMsg }
    
    private let _loginWithOAuth: (_ credential: OAuthCredential) async throws -> Void
    private let _loginWithAuth: (_ credential: AuthCredential) throws -> Void
    private let _login: (_ email: String, _ password: String) async throws -> Void
    
    private let _register: (_ email: String, _ password: String) async throws -> Void
    
    private let _logout: () -> Void
    private let _addListeners: () -> Void
    private let _saveProfile: (_ name: String) -> Void
    private var cancellable = Set<AnyCancellable>()
    
    init<U: FirebaseAuthServiceProtocol>(_ service: U) where U.UserType == T {
        _login = service.login(_:_:)
        _loginWithAuth = service.login(_:)
        _loginWithOAuth = service.login(_:)
        _register = service.register(_:_:)
        _logout = service.logout
        _addListeners = service.addListeners
        _saveProfile = service.saveProfile(name:)
        
        user = service.user
        errorMsg = service.errorMsg
        
        service.userPublisher.sink { [weak self] user in
            self?.user = user
        }.store(in: &cancellable)
        
        service.profilePublisher.sink { [weak self] profile in
            self?.profile = profile
        }.store(in: &cancellable)
        
        service.isLoadingPublisher.sink { [weak self] isLoading in
            self?.isLoading = isLoading
        }.store(in: &cancellable)
    }
 
    func login(_ email: String, _ password: String) async throws {
        try await _login(email, password)
    }
    
    func register(_ email: String, _ password: String) async throws {
        try await _register(email, password)
    }
    
    func logout() {
        _logout()
    }
    
    func login(_ credential: OAuthCredential) async throws {
        try await _loginWithOAuth(credential)
    }
    
    func login(_ credential: AuthCredential) throws {
        try _loginWithAuth(credential)
    }
    
    func addListeners() {
        _addListeners()
    }
    
    func saveProfile(name: String) {
        _saveProfile(name)
    }
}

extension AuthServiceProtocol {
    var isAuthenticated: Bool {
        self.user != nil
    }
    
}
