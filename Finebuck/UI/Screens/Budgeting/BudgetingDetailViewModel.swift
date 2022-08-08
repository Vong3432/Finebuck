//
//  BudgetingDetailViewModel.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 03/05/2022.
//

import Foundation
import Resolver
import FirebaseAuth

extension BudgetingDetailView {
    
    class BudgetingDetailViewModel: ObservableObject {
        
        var budgeting: Budgeting?
        @Published var costs = [Budgeting.Cost]()
        @Published var earnings = [Budgeting.Earning]()
        
        @Published private(set) var selectedCalculationItem: BudgetItem? = nil
        @Published var title: String = ""
        @Published private(set) var isEditingTitle = false
        @Published private(set) var isLoading = false
        @Published private(set) var error: BudgetsDBRepositoryError? = nil
        
        @Injected private var dataService: BudgetsDBRepositoryProtocol
        private var authService: AnyFirebaseAuthService<User>
        
        init(budgeting: Budgeting? = nil, authService: AnyFirebaseAuthService<User>) {
            self.budgeting = budgeting
            self.costs = budgeting?.costs.sorted() ?? []
            self.earnings = budgeting?.earning.sorted() ?? []
            self.authService = authService
            preset()
        }
        
        deinit {
            print("DEINIT")
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
        func saveToCloud() {
            Task {
                do {
                    // Ensure everything is up-to-date
                    saveBudgeting(budgetItem: nil)
                    
                    guard let budgeting = budgeting, let saved = try await dataService.save(budgeting) else {
                        throw BudgetsDBRepositoryError.failed
                    }
                    
                    // Set the updated budgeting locally
                    DispatchQueue.main.async {
                        self.budgeting = saved
                    }
                }
                catch BudgetsDBRepositoryError.noResult {
                    DispatchQueue.main.async {
                        self.error = .noResult
                    }
                }
                catch BudgetsDBRepositoryError.notAuthenticated {
                    DispatchQueue.main.async {
                        self.error = .notAuthenticated
                    }
                }
                catch BudgetsDBRepositoryError.failed {
                    DispatchQueue.main.async {
                        self.error = .failed
                    }
                } catch {
                    fatalError("Unexpected error")
                }
            }
        }
        
        func saveBudgeting(budgetItem: BudgetItem?) {
            guard let user = authService.user else { return }
            
            let savedBudgeting = Budgeting(
                id: budgeting?.id,
                title: title,
                costs: costs,
                earning: earnings,
                currency: budgeting?.currency ?? .myr,
                creatorUid: user.uid
            )
            
            self.budgeting = savedBudgeting
            saveBudgetItem(of: savedBudgeting, budgetItem: budgetItem)
        }
        
        private func saveBudgetItem(of budgeting: Budgeting, budgetItem: BudgetItem?) {
            guard let budgetItem = budgetItem, let user = authService.user else { return }
            
            let updatedBudgeting = Budgeting(id: budgeting.id, title: budgeting.title, costs: costs, earning: earnings, currency: budgeting.currency, creatorUid: user.uid)
            
            let isEditingBudgetItem = selectedCalculationItem != nil
            
            switch budgetItem.itemIdentifier {
                
            case .cost:
                var cost = Budgeting.Cost(id: budgetItem.id, budgetingID: budgeting.id, itemIdentifier: .cost, title: budgetItem.title, type: budgetItem.type, value: budgetItem.value, rate: budgetItem.rate, currency: budgetItem.currency, index: budgetItem.index)
                
                if isEditingBudgetItem {
                    let idx = costs.firstIndex { $0.id == budgetItem.id }
                    guard let idx = idx else { return }
                    
                    costs[idx] = cost
                } else {
                    cost.index = costs.count - 1
                    costs.append(cost)
                }
                
            case .earning:
                var earning = Budgeting.Earning(id: budgetItem.id, budgetingID: budgeting.id, itemIdentifier: .earning, title: budgetItem.title, type: budgetItem.type, value: budgetItem.value, rate: budgetItem.rate, currency: budgetItem.currency, index: budgetItem.index)
                
                if isEditingBudgetItem {
                    let idx = earnings.firstIndex { $0.id == budgetItem.id }
                    guard let idx = idx else { return }
                    
                    earnings[idx] = earning
                } else {
                    earning.index = earnings.count - 1
                    earnings.append(earning)
                }
            }
            
            self.budgeting = updatedBudgeting
        }
    }
}
