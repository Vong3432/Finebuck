//
//  Template.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 23/04/2022.
//

import Foundation

struct Template: Codable, Identifiable {
    var id = UUID().uuidString
    let title: String
    let description: String
    let category: Category
    
    enum Category: String, Codable {
        case custom = "Custom"
        case defaultCategory = "Default"
    }
}

extension Template {
    static let mockedTemplates = [
        Template(title: "Starter Template", description: "Basic labels ", category: .defaultCategory),
        Template(title: "Travel plan", description: "Budget plan", category: .custom),
    ]
}
