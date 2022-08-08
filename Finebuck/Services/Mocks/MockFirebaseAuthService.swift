//
//  MockFirebaseAuthService.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 09/08/2022.
//

import Foundation
import FirebaseAuth

final class MockFirebaseAuthService: FirebaseAuthServiceProtocol {
    @Published var user: User?
    var userPublisher: Published<User?> { _user }
    var userPublished: Published<User?>.Publisher {$user}
    
    @Published var errorMsg: String?
    var errorMsgPublisher: Published<String?> { _errorMsg }
    var errorMsgPublished: Published<String?>.Publisher { $errorMsg }
    
    func login(_ email: String, _ password: String) async throws {
        
    }
    
    func register(_ email: String, _ password: String) async throws {
        
    }
    
    func logout() {
        
    }
    
    func login(_ credential: OAuthCredential) async throws {
        
    }
    
    func login(_ credential: AuthCredential) throws {
        
    }
    
    func addListeners() {
        
    }
    
    
}

final class MockFirebaseAuthServiceFailed: FirebaseAuthServiceProtocol {
    @Published var user: User?
    var userPublisher: Published<User?> { _user }
    var userPublished: Published<User?>.Publisher {$user}
    
    @Published var errorMsg: String?
    var errorMsgPublisher: Published<String?> { _errorMsg }
    var errorMsgPublished: Published<String?>.Publisher { $errorMsg }
    
    func login(_ email: String, _ password: String) async throws {
        throw AuthError.incorrect
    }
    
    func register(_ email: String, _ password: String) async throws {
        throw AuthError.registered
    }
    
    func logout() {
        
    }
    
    func login(_ credential: OAuthCredential) async throws {
        throw AuthError.incorrect
    }
    
    func login(_ credential: AuthCredential) throws {
        throw AuthError.incorrect
    }
    
    func addListeners() {
        
    }
    
    
}

