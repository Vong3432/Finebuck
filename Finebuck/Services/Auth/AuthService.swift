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
    //    associatedtype UserType
    
    var user: User? { get set }
    var userPublisher: Published<User?> { get }
    var userPublished: Published<User?>.Publisher { get }
    
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

extension AuthServiceProtocol {
    var isAuthenticated: Bool {
        self.user != nil
    }
    
}
