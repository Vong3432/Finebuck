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
        // UI
        @Published private(set) var rateFieldOpacity: Double = 0
        @Published private(set) var fixedAmountFieldOpacity: Double = 1
        // Form fields and info
        @Published var label = ""
        @Published var amount: Double?
        @Published var rate: Double?
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
        
        init(budgetItem: BudgetItem?) {
            self.calculationItem = budgetItem
            
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
            
            switchCalculateType(to: budgetCalculateType)
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
        
        func save() -> BudgetItem? {
            let saved = Budgeting.Cost(
                id: calculationItem?.id ?? UUID().uuidString,
                itemIdentifier: itemIdentifier,
                title: label,
                type: budgetCalculateType,
                value: amount!,
                rate: rate,
                currency: currency
            )

            return saved
        }
    }
}
