//
//  Budgeting.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 24/04/2022.
//

import Foundation

protocol BudgetItem {
    var title: String { get }
    var type: Budgeting.CalculateType { get }
    var value: Double { get }
    var rate: Double? { get }
    var currencySymbol: String { get }
    var currencyCode: String { get }
    var formattedCost: String { get }
}

struct Budgeting: Codable, Identifiable {
    var id = UUID().uuidString
    let title: String
    let costs: [Cost]
    let earning: [Earning]
    let currencySymbol: String
    let currencyCode: String
    
    struct Cost: Codable, BudgetItem, Identifiable {
        var id = UUID().uuidString
        let title: String
        let type: CalculateType
        let value: Double
        let rate: Double?
        let currencySymbol: String
        let currencyCode: String
        
        var formattedCost: String {
            return value.asCurrencyWith2Decimals(currencyCode: currencyCode, currencySymbol: currencySymbol)
        }
    }
    
    struct Earning: Codable, BudgetItem, Identifiable {
        var id = UUID().uuidString
        let title: String
        let type: CalculateType
        let value: Double
        let rate: Double?
        let currencySymbol: String
        let currencyCode: String
        
        var formattedCost: String {
            return value.asCurrencyWith2Decimals(currencyCode: currencyCode, currencySymbol: currencySymbol)
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
        return net.asCurrencyWith2Decimals(currencyCode: currencyCode, currencySymbol: currencySymbol)
    }
}

extension Budgeting {
    static let mockBudgetingItems = [
        Budgeting(
            title: "Budgeting Plan 1",
            costs: [
                Cost(title: "Cost", type: .fixed, value: 5.0, rate: nil, currencySymbol: "RM",
                     currencyCode: "MYR")
            ],
            earning: [
                Earning(title: "Salary", type: .fixed, value: 5.0, rate: nil, currencySymbol: "RM",
                        currencyCode: "MYR")
            ],
            currencySymbol: "RM",
            currencyCode: "MYR"
        )
    ]
}
