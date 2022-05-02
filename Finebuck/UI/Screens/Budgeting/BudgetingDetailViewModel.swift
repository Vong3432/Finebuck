//
//  BudgetingDetailViewModel.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 03/05/2022.
//

import Foundation

extension BudgetingDetailView {
    class BudgetingDetailViewModel: ObservableObject {
        
        var budgeting: Budgeting?
        @Published private(set) var selectedCalculationItem: BudgetItem? = nil
        @Published var title: String = ""
        @Published private(set) var isEditingTitle = false
        
        init(budgeting: Budgeting?) {
            self.budgeting = budgeting
            preset()
        }
        
        private func preset() {
            title = budgeting?.title ?? "Budgeting"
        }
        
        func startEditingTitle() {
            isEditingTitle = true
        }

        func endEditingTitle() {
            isEditingTitle = false
        }
        
        func viewBudgetItem(_ budgetItem: BudgetItem?) {
            selectedCalculationItem = budgetItem
        }
    }
}
