//
//  Currency.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 03/05/2022.
//

import Foundation

protocol CurrencyProtocol: Identifiable {
    var id: String { get }
    var currencyCode: String { get }
    var currencySymbol: String { get }
}

struct Currency: CurrencyProtocol, Identifiable, Codable {
    var id = UUID().uuidString
    let currencyCode: String
    let currencySymbol: String
}

// simple way
extension Currency {
    static let myr = Currency(currencyCode: "MYR", currencySymbol: "RM")
    static let sgd = Currency(currencyCode: "SGD", currencySymbol: "$")
    
    static let supportedCurrencies = [myr, sgd]
}
