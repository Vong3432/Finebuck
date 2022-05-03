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
        private let dataService: BudgetsDataServiceProtocol
        
        // UI
        @Published private(set) var rateFieldOpacity: Double = 0
        @Published private(set) var fixedAmountFieldOpacity: Double = 1
        
        // Form fields and info
        @Published var label = ""
        @Published var amount: Double? = nil
        @Published var rate: Double? = nil
        @Published private(set) var itemIdentifier: ItemIdentifier = .cost
        @Published private(set) var budgetCalculateType: Budgeting.CalculateType = .fixed
        @Published private(set) var currency: Currency = .myr
        
        var shouldDisableDoneBtn: Bool {
            if label.trimmingCharacters(in: .whitespaces).isEmpty || amount == nil { return true }
            
            if budgetCalculateType == .rate {
                if rate == nil {
                    return true
                }
            }
            
            return false
        }
        
        init(budgetItem: BudgetItem?, dataService: BudgetsDataServiceProtocol) {
            self.calculationItem = budgetItem
            self.dataService = dataService
            
            preset()
        }
        
        private func preset() {
            guard let calculationItem = calculationItem else { return }

            label = calculationItem.title
            amount = calculationItem.value
            rate = calculationItem.rate
            itemIdentifier = calculationItem.itemIdentifier
            budgetCalculateType = calculationItem.type
            currency = calculationItem.currency
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
        
        func switchFormType(to identifier: ItemIdentifier) {
            itemIdentifier = identifier
        }
        
        /// ** !!! Haven't add to UI !!! **
        func switchCurrencyType(to currency: Currency) {
            self.currency = currency
        }
    }
}
