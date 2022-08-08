//
//  String.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 25/04/2022.
//

import Foundation

extension String {
    func firstChar() -> String {
        return String(self.prefix(1))
    }
}

// MARK: - Firebase collection path
extension String {
    static let firestoreBudgetingsPath = "budgetings"
    static let firestoreTemplatesPath = "templates"
    static let firestoreProfilesPath = "profiles"
}
