//
//  Profile.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 08/08/2022.
//

import Foundation
import FirebaseFirestoreSwift

struct Profile: Codable, Identifiable {
    @DocumentID var id: String?
    let username: String
    let email: String
    let avatarUrl: String?
}

#if DEBUG
extension Profile {
    static let profile = Profile(username: "John Doe", email: "johndoe@gmail.com", avatarUrl: "")
}
#endif
