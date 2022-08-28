//
//  Budgeting.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 24/04/2022.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

enum ItemIdentifier: String, Codable { case cost = "cost", earning = "earning" }

protocol BudgetItem {
    var id: String? { get }
//    var budgetingID: String? { get set }
    var itemIdentifier: ItemIdentifier { get set }
    var title: String { get set }
    var type: Budgeting.CalculateType { get set}
    var value: Double { get set}
    var rate: Double? { get set}
    var currency: Currency { get set}
    var formattedValue: String { get }
    var calculatedValue: Double { get }
    var index: Int? { get set }
}

struct Budgeting: Codable, Identifiable, Equatable, Comparable {
    static func == (lhs: Budgeting, rhs: Budgeting) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title
    }
    
    static func < (lhs: Budgeting, rhs: Budgeting) -> Bool {
        guard let lI = lhs.createdAt, let rI = rhs.createdAt else { return false }
        return lI.dateValue() <= rI.dateValue()
    }
    
    @DocumentID var id: String?
    var title: String
//    lazy var costs: [Cost] = []
//    lazy var earning: [Earning] = []
    var currency: Currency
    var creatorUid: String
    var index: Int?
    var createdAt: Timestamp?
    
    struct Cost: Codable, BudgetItem, Identifiable, Equatable, Comparable {
        static func < (lhs: Budgeting.Cost, rhs: Budgeting.Cost) -> Bool {
            guard let lI = lhs.index, let rI = rhs.index else { return false }
            return lI < rI
        }
        
        static func == (lhs: Budgeting.Cost, rhs: Budgeting.Cost) -> Bool {
            lhs.id == rhs.id
        }
        
        var id: String? = UUID().uuidString
//        var budgetingID: String?
        var itemIdentifier: ItemIdentifier
        var title: String
        var type: CalculateType
        var value: Double
        var rate: Double?
        var currency: Currency
        var index: Int?
        
        var formattedValue: String {
            return calculatedValue.asCurrencyWith2Decimals(currency: currency)
        }
        
        var calculatedValue: Double {
            if type == .fixed {
                return value
            }
            else {
                guard let rate = rate else { fatalError() }
                let after = value * rate
                return after
            }
        }
    }
    
    struct Earning: Codable, BudgetItem, Identifiable, Comparable, Equatable {
        static func == (lhs: Budgeting.Earning, rhs: Budgeting.Earning) -> Bool {
            lhs.id == rhs.id
        }
        
        static func < (lhs: Budgeting.Earning, rhs: Budgeting.Earning) -> Bool {
            guard let lI = lhs.index, let rI = rhs.index else { return false }
            return lI < rI
        }
        
        var id: String? = UUID().uuidString
//        var budgetingID: String?
        var itemIdentifier: ItemIdentifier
        var title: String
        var type: CalculateType
        var value: Double
        var rate: Double?
        var currency: Currency
        var index: Int?
        
        var formattedValue: String {
            return calculatedValue.asCurrencyWith2Decimals(currency: currency)
        }
        
        var calculatedValue: Double {
            if type == .fixed {
                return value
            }
            else {
                guard let rate = rate else { fatalError() }
                let after = value * rate
                return after
            }
        }
    }
    
    enum CalculateType: String, Codable {
        case fixed = "Fixed"
        case rate = "Rate"
    }
    
    var net: Double {
        let sumCosts = costs.map { $0.calculatedValue }.reduce(0, +)
        let sumEarning = earning.map { $0.calculatedValue }.reduce(0, +)
        
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
                Cost(itemIdentifier: .cost, title: "Cost", type: .fixed, value: 5.0, rate: nil, currency: .myr),
                Cost(itemIdentifier: .cost, title: "Cost", type: .fixed, value: 5.0, rate: nil, currency: .myr)
            ],
            earning: [
                Earning(itemIdentifier: .earning, title: "Salary", type: .fixed, value: 5.0, rate: nil, currency: .myr)
            ],
            currency: .myr,
            creatorUid: "123"
        ),
        Budgeting(
            id: "B2",
            title: "Budgeting Plan 2",
            costs: [
                Cost(itemIdentifier: .cost, title: "Cost", type: .fixed, value: 5.0, rate: nil, currency: .myr)
            ],
            earning: [
                Earning(itemIdentifier: .earning, title: "Salary", type: .fixed, value: 5.0, rate: nil, currency: .sgd)
            ],
            currency: .sgd,
            creatorUid: "123"
        )
    ]
}
