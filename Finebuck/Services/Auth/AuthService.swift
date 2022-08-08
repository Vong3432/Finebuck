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
    var userPublisher: Published<UserType?> { get }
    var userPublished: Published<UserType?>.Publisher { get }
    
    var errorMsg: String? { get set }
    var errorMsgPublisher: Published<String?> { get }
    var errorMsgPublished: Published<String?>.Publisher { get }
    
    func addListeners() -> Void
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
class AnyFirebaseAuthService<T>: FirebaseAuthServiceProtocol {
    typealias UserType = T
    
    @Published var user: T?
    var userPublisher: Published<T?> { _user }
    var userPublished: Published<T?>.Publisher { $user }
    
    @Published var errorMsg: String?
    var errorMsgPublisher: Published<String?> { _errorMsg }
    var errorMsgPublished: Published<String?>.Publisher { $errorMsg }
    
    private let _loginWithOAuth: (_ credential: OAuthCredential) async throws -> Void
    private let _loginWithAuth: (_ credential: AuthCredential) throws -> Void
    private let _login: (_ email: String, _ password: String) async throws -> Void
    
    private let _register: (_ email: String, _ password: String) async throws -> Void
    private let _logout: () -> Void
    
    private let _addListeners: () -> Void
    
    init<U: FirebaseAuthServiceProtocol>(_ service: U) where U.UserType == T {
        _login = service.login(_:_:)
        _loginWithAuth = service.login(_:)
        _loginWithOAuth = service.login(_:)
        _register = service.register(_:_:)
        _logout = service.logout
        _addListeners = service.addListeners
        
        user = service.user
        errorMsg = service.errorMsg
        
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
}

extension AuthServiceProtocol {
    var isAuthenticated: Bool {
        self.user != nil
    }
    
}
