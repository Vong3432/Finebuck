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
        @Published private(set) var isLoading = false
        @Published private(set) var error: BudgetsDBRepositoryError? = nil
        
        private let dataService: BudgetsDBRepositoryProtocol
        
        init(budgeting: Budgeting? = nil, dataService: BudgetsDBRepositoryProtocol) {
            self.budgeting = budgeting
            self.dataService = dataService
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
        
        /*
         Tasks
         -------------
         1. Create/update the Budgeting and return saved budgeting.
         2. Use the saved budgeting and perform create/update budgetItem
         
         Pseudocode
         -------------
         saveBudgeting { returnedBudgeting in
         
             If "selectedCalculationItem" is nil, means is creating new budgetItem
             
             IF isEditingBudgetItem
                updateBudgetItem(of: returnedBudgeting, item: budgetItem)
             ELSE
                createBudgetItem(of: returnedBudgeting, item: budgetItem)
         
         }
         
         */
        func saveBudgeting(budgetItem: BudgetItem?) {
            let savedBudgeting = Budgeting(
                title: title,
                costs: budgeting?.costs ?? [],
                earning: budgeting?.earning ?? [],
                currency: budgeting?.currency ?? .myr)
            
            dataService.save(savedBudgeting) { [weak self] result in
                switch result {
                case .failure(let error):
                    self?.error = error
                    break
                case .success(let save):
                    self?.budgeting = save
                    self?.saveBudgetItem(of: save, budgetItem: budgetItem)
                    break
                }
            }
        }
        
        private func saveBudgetItem(of budgeting: Budgeting, budgetItem: BudgetItem?) {
            guard let budgetItem = budgetItem else { return }
            
            var updatedBudgeting = Budgeting(id: budgeting.id, title: budgeting.title, costs: budgeting.costs, earning: budgeting.earning, currency: budgeting.currency)
            
            let isEditingBudgetItem = selectedCalculationItem != nil
            
            switch budgetItem.itemIdentifier {
                
            case .cost:
                let cost = Budgeting.Cost(id: budgetItem.id, budgetingID: budgeting.id, itemIdentifier: .cost, title: budgetItem.title, type: budgetItem.type, value: budgetItem.value, rate: budgetItem.rate, currency: budgetItem.currency)
                
                if isEditingBudgetItem {
                    let idx = updatedBudgeting.costs.firstIndex { $0.id == budgetItem.id }
                    guard let idx = idx else { return }
                    
                    updatedBudgeting.costs[idx] = cost
                } else {
                    updatedBudgeting.costs.append(cost)
                }
                
            case .earning:
                let earning = Budgeting.Earning(id: budgetItem.id, budgetingID: budgeting.id, itemIdentifier: .earning, title: budgetItem.title, type: budgetItem.type, value: budgetItem.value, rate: budgetItem.rate, currency: budgetItem.currency)
                
                if isEditingBudgetItem {
                    let idx = updatedBudgeting.earning.firstIndex { $0.id == budgetItem.id }
                    guard let idx = idx else { return }
                    
                    updatedBudgeting.earning[idx] = earning
                } else {
                    updatedBudgeting.earning.append(earning)
                }
            }
            
            // Updates to server
            dataService.update(budgeting, with: updatedBudgeting) { [weak self] result in
                switch result {
                case .failure(let err):
                    self?.error = err
                case .success(let save):
                    self?.budgeting = save
                }
            }
            
        }
    }
}
