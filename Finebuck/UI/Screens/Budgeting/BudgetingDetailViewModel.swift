//
//  BudgetingDetailViewModel.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 03/05/2022.
//

import Foundation
import Resolver
import FirebaseAuth
import SwiftUI

extension BudgetingDetailView {
    
    class BudgetingDetailViewModel: ObservableObject {
        
        @Published var budgeting: Budgeting?
        
        /// Created local instances to make sure UI can capture updates from budgeting even though they are already in inside of `budgeting` variable.
        @Published var costs = [Budgeting.Cost]()
        @Published var earnings = [Budgeting.Earning]()
        
        @Published private(set) var selectedCalculationItem: BudgetItem? = nil
        @Published var title: String = ""
        @Published private(set) var isEditingTitle = false
        @Published private(set) var isLoading = false
        @Published private(set) var error: FirestoreDBRepositoryError? = nil
        
        @Injected private var dataService: AnyFirestoreDBRepository<Budgeting>
        var authService: AnyFirebaseAuthService<User>?
        
        init(budgeting: Budgeting? = nil, authService: AnyFirebaseAuthService<User>) {
            self.budgeting = budgeting
            self.costs = budgeting?.costs.sorted() ?? []
            self.earnings = budgeting?.earning.sorted() ?? []
            self.authService = authService
            preset()
        }
        
        deinit {
            print("BudgetDetailVM DEINIT")
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
        
        // MARK: - Save budget data to firestore
        func saveToCloud() {
            Task { @MainActor in
                // Ensure everything is up-to-date
                saveBudgeting(budgetItem: nil)
                
                guard let budgeting = budgeting else { return }
                let savedBudgeting: Budgeting!
                
                do {
                    self.isLoading = true
                    savedBudgeting = try await dataService.save(budgeting)
                    self.isLoading = false
                    self.budgeting = savedBudgeting
                } catch let error {
                    debugPrint(error)
                    if let error = error as? FirestoreDBRepositoryError {
                        self.error = error
                    }
                }
            }
        }
        
        // MARK: - Save budget data to local state
        func saveBudgeting(budgetItem: BudgetItem?) {
            guard let user = authService?.user else { return }
            
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
            guard let budgetItem = budgetItem, let user = authService?.user else { return }
            
            var updatedBudgeting = Budgeting(id: budgeting.id, title: budgeting.title, costs: costs, earning: earnings, currency: budgeting.currency, creatorUid: user.uid)
            
            let isEditingBudgetItem = selectedCalculationItem != nil
            
            switch budgetItem.itemIdentifier {
            case .cost:
                var cost = Budgeting.Cost(id: budgetItem.id, itemIdentifier: budgetItem.itemIdentifier, title: budgetItem.title, type: budgetItem.type, value: budgetItem.value, rate: budgetItem.rate, currency: budgetItem.currency, index: budgetItem.index)
                
                if isEditingBudgetItem {
                    let idx = costs.firstIndex { $0.id == budgetItem.id }
                    if let idx = idx {
                        // Simple update, users did not change identifier
                        costs[idx] = cost
                    } else {
                        /// We know that users have changed the identifier because it is not in the cost list while was in editing mode previously
                        /// So we find index from `earnings`
                        let earIdx = earnings.firstIndex { $0.id == budgetItem.id }
                        guard let earIdx = earIdx else {
                            fatalError("Something went wrong!")
                        }
                        
                        /// Remove from `earnings`
                        earnings.remove(at: earIdx)
                        
                        /// Append to `costs` as usual for new budgetItem.
                        cost.index = costs.count > 0 ? costs.count : 0
                        costs.append(cost)
                    }
                } else {
                    cost.index = costs.count > 0 ? costs.count : 0
                    costs.append(cost)
                }
                
            case .earning:
                var earning = Budgeting.Earning(id: budgetItem.id, itemIdentifier: budgetItem.itemIdentifier, title: budgetItem.title, type: budgetItem.type, value: budgetItem.value, rate: budgetItem.rate, currency: budgetItem.currency, index: budgetItem.index)
                
                if isEditingBudgetItem {
                    let idx = earnings.firstIndex { $0.id == budgetItem.id }
                    if let idx = idx {
                        // Simple update, users did not change identifier
                        earnings[idx] = earning
                    } else {
                        /// We know that users have changed the identifier because it is not in the earning list while was in editing mode previously
                        /// So we find index from `costs`
                        let cosIdx = costs.firstIndex { $0.id == budgetItem.id }
                        guard let cosIdx = cosIdx else {
                            fatalError("Something went wrong!")
                        }
                        
                        /// Remove from `costs`
                        costs.remove(at: cosIdx)
                        
                        /// Append to `earnings` as usual for new budgetItem.
                        earning.index = earnings.count > 0 ? earnings.count : 0
                        earnings.append(earning)
                    }
                    
                } else {
                    earning.index = earnings.count > 0 ? earnings.count : 0
                    earnings.append(earning)
                }
            }
            updatedBudgeting.costs = costs
            updatedBudgeting.earning = earnings
            
            DispatchQueue.main.async {
                self.budgeting = updatedBudgeting
            }
        }
        
        // MARK: - Delete budget item from firestore
        func deleteBudgetItem(of budgetItem: BudgetItem) {
            switch budgetItem.itemIdentifier {
            case .earning:
                let idx = earnings.firstIndex { $0.id == budgetItem.id }
                guard let idx = idx else { return }
                
                withAnimation(.spring()) {
                    _ = self.earnings.remove(at: idx)
                }
                
                budgeting?.earning = earnings
            case .cost:
                let idx = costs.firstIndex { $0.id == budgetItem.id }
                guard let idx = idx else { return }
                
                withAnimation(.spring()) {
                    _ = self.costs.remove(at: idx)
                }
                
                budgeting?.costs = costs
            }
        }
    }
}
