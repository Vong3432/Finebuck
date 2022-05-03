//
//  Budgeting.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 24/04/2022.
//

import Foundation

enum ItemIdentifier: String, Codable { case cost = "cost", earning = "earning" }

protocol BudgetItem {
    var id: String { get }
    var itemIdentifier: ItemIdentifier { get }
    var title: String { get }
    var type: Budgeting.CalculateType { get }
    var value: Double { get }
    var rate: Double? { get }
    var currency: Currency { get }
    var formattedValue: String { get }
}

struct Budgeting: Codable, Identifiable {
    var id = UUID().uuidString
    let title: String
    let costs: [Cost]
    let earning: [Earning]
    let currency: Currency
    
    struct Cost: Codable, BudgetItem, Identifiable {
        var id = UUID().uuidString
        let itemIdentifier: ItemIdentifier
        let title: String
        let type: CalculateType
        let value: Double
        let rate: Double?
        let currency: Currency
        
        var formattedValue: String {
            return value.asCurrencyWith2Decimals(currency: currency)
        }
    }
    
    struct Earning: Codable, BudgetItem, Identifiable {
        var id = UUID().uuidString
        let itemIdentifier: ItemIdentifier
        let title: String
        let type: CalculateType
        let value: Double
        let rate: Double?
        let currency: Currency
        
        var formattedValue: String {
            return value.asCurrencyWith2Decimals(currency: currency)
        }
    }
    
    enum CalculateType: String, Codable {
        case fixed = "Fixed"
        case rate = "Rate"
    }
    
    var net: Double {
        let sumCosts = costs.map { $0.value }.reduce(0, +)
        let sumEarning = earning.map { $0.value }.reduce(0, +)
        
        return sumEarning - sumCosts
    }
    
    var formattedNet: String {
        return net.asCurrencyWith2Decimals(currency: currency)
    }
}

extension Budgeting {
    static let mockBudgetingItems = [
        Budgeting(
            title: "Budgeting Plan 1",
            costs: [
                Cost(itemIdentifier: .cost, title: "Cost", type: .fixed, value: 5.0, rate: nil, currency: .myr)
            ],
            earning: [
                Earning(itemIdentifier: .earning, title: "Salary", type: .fixed, value: 5.0, rate: nil, currency: .myr)
            ],
            currency: .myr
        ),
        Budgeting(
            title: "Budgeting Plan 2",
            costs: [
                Cost(itemIdentifier: .cost, title: "Cost", type: .fixed, value: 5.0, rate: nil, currency: .myr)
            ],
            earning: [
                Earning(itemIdentifier: .earning, title: "Salary", type: .fixed, value: 5.0, rate: nil, currency: .sgd)
            ],
            currency: .sgd
        )
    ]
}
