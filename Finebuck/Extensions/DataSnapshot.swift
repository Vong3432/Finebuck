//
//  DataSnapshot.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 04/05/2022.
//

import Foundation
import FirebaseDatabaseSwift
import FirebaseDatabase

extension DataSnapshot {
    
    /// Transform every snapshot children to T type and return transformed list.
    static func mapChildren<T: Codable>(_ children: NSEnumerator) -> [T]? {
        guard let children = children.allObjects as? [DataSnapshot] else {
            return nil
        }
        
        let mapped = children.compactMap { snapshot in
            return try? snapshot.data(as: T.self)
        }
        
        return mapped
    }
}
