//
//  BudgetPlanDetailFormViewModel.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 03/05/2022.
//

import Foundation

extension BudgetPlanDetailFormView {
    class BudgetPlanDetailFormViewModel: ObservableObject {
        let calculationItem: BudgetItem?
        
        @Published private(set) var rateFieldOpacity: Double = 0
        @Published private(set) var fixedAmountFieldOpacity: Double = 1
        
        @Published var label = ""
        @Published var amount: Double? = nil
        @Published var rate: Double? = nil
        @Published private(set) var isCost = true
        @Published private(set) var budgetCalculateType: Budgeting.CalculateType = .fixed
        
        var shouldDisableDoneBtn: Bool {
            if label.trimmingCharacters(in: .whitespaces).isEmpty || amount == nil { return true }
            
            if budgetCalculateType == .rate {
                if rate == nil {
                    return true
                }
            }
            
            return false
        }
        
        init(budgetItem: BudgetItem?) {
            self.calculationItem = budgetItem
        }
        
        func switchCalculateType(to calculateType: Budgeting.CalculateType) {
            if calculateType == .fixed {
                rateFieldOpacity = 0
                fixedAmountFieldOpacity = 1
            } else {
                rateFieldOpacity = 1
                fixedAmountFieldOpacity = 0
            }
            
            budgetCalculateType = calculateType
        }
        
        func switchFormType(isCost: Bool) {
            self.isCost = isCost
        }
    }
}
