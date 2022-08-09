//
//  ProfileRepository.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 08/08/2022.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol ProfileRepositoryProtocol {
    func save(_ user: User, name: String) async throws -> Profile?
    func get(_ documentID: String) async throws -> Profile?
}

final class ProfileRepository: ProfileRepositoryProtocol {
    private let store = Firestore.firestore()
    private let path = "profiles"
    
    func save(_ user: User, name: String) async throws -> Profile? {
        let newProfile = Profile(username: name, email: user.email!, avatarUrl: user.photoURL?.absoluteString)
        try store.collection(path).document(user.uid).setData(from: newProfile, merge: true)
        return try await get(user.uid)
    }
    
    func get(_ documentID: String) async throws -> Profile? {
        return try await store.collection(path).document(documentID).getDocument(as: Profile.self)
    }
    
}
