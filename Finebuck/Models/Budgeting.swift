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
    var budgetingID: String? { get set }
    var itemIdentifier: ItemIdentifier { get set }
    var title: String { get set }
    var type: Budgeting.CalculateType { get set}
    var value: Double { get set}
    var rate: Double? { get set}
    var currency: Currency { get set}
    var formattedValue: String { get }
}

struct Budgeting: Codable, Identifiable, Equatable {
    static func == (lhs: Budgeting, rhs: Budgeting) -> Bool {
        lhs.id == rhs.id
    }
    
    var id = UUID().uuidString
    var title: String
    var costs: [Cost]
    var earning: [Earning]
    var currency: Currency
    
    struct Cost: Codable, BudgetItem, Identifiable {
        var id = UUID().uuidString
        var budgetingID: String?
        var itemIdentifier: ItemIdentifier
        var title: String
        var type: CalculateType
        var value: Double
        var rate: Double?
        var currency: Currency
        
        var formattedValue: String {
            if type == .fixed {
                return value.asCurrencyWith2Decimals(currency: currency)
            }
            else {
                guard let rate = rate else { fatalError() }
                let after = value * (100 - (rate * 100)) / 100
                return after.asCurrencyWith2Decimals(currency: currency)
            }
        }
    }
    
    struct Earning: Codable, BudgetItem, Identifiable {
        var id = UUID().uuidString
        var budgetingID: String?
        var itemIdentifier: ItemIdentifier
        var title: String
        var type: CalculateType
        var value: Double
        var rate: Double?
        var currency: Currency
        
        var formattedValue: String {
            if type == .fixed {
                return value.asCurrencyWith2Decimals(currency: currency)
            }
            else {
                guard let rate = rate else { fatalError() }
                let after = value * (100 - (rate * 100)) / 100
                return after.asCurrencyWith2Decimals(currency: currency)
            }
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
            id: "B1",
            title: "Budgeting Plan 1",
            costs: [
                Cost(budgetingID: "ABC", itemIdentifier: .cost, title: "Cost", type: .fixed, value: 5.0, rate: nil, currency: .myr)
            ],
            earning: [
                Earning(budgetingID: "ABC", itemIdentifier: .earning, title: "Salary", type: .fixed, value: 5.0, rate: nil, currency: .myr)
            ],
            currency: .myr
        ),
        Budgeting(
            id: "B2",
            title: "Budgeting Plan 2",
            costs: [
                Cost(budgetingID: "ABCD", itemIdentifier: .cost, title: "Cost", type: .fixed, value: 5.0, rate: nil, currency: .myr)
            ],
            earning: [
                Earning(budgetingID: "ABCD", itemIdentifier: .earning, title: "Salary", type: .fixed, value: 5.0, rate: nil, currency: .sgd)
            ],
            currency: .sgd
        )
    ]
}
