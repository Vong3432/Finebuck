//
//  FirebaseDatabaseManager.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 04/05/2022.
//

import Foundation
import FirebaseDatabase


// - source: https://github.com/oguzparlak/FirebaseWrapper/blob/main/Firebase/Database/FirebaseDatabaseManager.swift
final class FirebaseDatabaseManager {
    
    static let shared = FirebaseDatabaseManager()
    
    let ref = Database.database().reference()
    
    private init() { }
    
    func write<T: Codable>(
        _ data: T,
        path: String,
        createAutoKey: Bool = false,
        completion: ((Result<T, Error>) -> Void)? = nil
    ) {
        
        var encodedData: Any?
        
        if let value = data.dictionary {
            encodedData = value
        }
        
        if let value = data.array {
            encodedData = value
        }
        
        guard let encodedData = encodedData else {
            completion?(.failure(FirebaseError.encodingError))
            return
        }
        
        var childRef = ref.child(path)
        
        if createAutoKey { childRef = childRef.childByAutoId() }
        
        childRef.setValue(encodedData) { error, _ in
            if let error = error { completion?(.failure(error)) }
            completion?(.success(data))
        }
    }
    
    func getDataOnce(path: String, completion: @escaping (Result<DataSnapshot, Error>) -> Void) {
        ref.child(path).observeSingleEvent(of: .value) { snapshot in
            completion(.success(snapshot))
        } withCancel: { error in
            print(error.localizedDescription)
            completion(.failure(error))
        }
    }
}

protocol FirebaseEndPointProtocol {
    var path: String { get }
}

enum FirebaseError: LocalizedError {
    case encodingError
    
    var errorDescription: String {
        switch self {
        case .encodingError:
            return "Fail to encode for firebase"
        }
    }
}


//enum FirebaseLocationHistory: FirebaseEndPointProtocol {
//    case saveHistory(userId: String, locationId: String)
//    case getHistories(userId: String)
//
//    var path: String {
//        switch self {
//        case .saveHistory(let userId, let locationId):
//            return "user_parkinglocations/\(userId)/locations/\(locationId)"
//        case .getHistories(let userId):
//            return "user_parkinglocations/\(userId)"
//        }
//    }
//}

// MARK: - "budgetings" schema
enum FirebaseLocationsEndPoint: FirebaseEndPointProtocol {
    case getAllBudgetings(uid: String)
    case saveBudgeting(uid: String)
    case getBudgeting(id: String)
    
    var path: String {
        switch self {
        case .getAllBudgetings(let uid), .saveBudgeting(let uid):
            return "budgetings/\(uid)"
        case .getBudgeting(let id):
            return "bugetings/\(id)"
        }
    }
}

// MARK: - "users" schema
enum FirebaseUsersEndPoint: FirebaseEndPointProtocol {
    case saveUser(id: String)
    case getUser(id: String)
    
    var path: String {
        switch self {
        case .getUser(let id), .saveUser(let id):
            return "users/\(id)"
        }
    }
}

