//
//  HomeViewModel.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 03/05/2022.
//

import Foundation
import Combine
import Resolver

extension HomeView {
    class HomeViewModel: ObservableObject {
        @Published private(set) var budgetings = [Budgeting]()
        @Injected private var dataService: BudgetsDBRepositoryProtocol
        private var cancellables = Set<AnyCancellable>()

        init() {            
            subscribe()
        }
        
        private func subscribe() {
            Task { [weak self] in
                await self?.loadBudgetings()
            }
            
            dataService.budgetingsPublisher
                .sink { [weak self] returnedBudgeting in
                    DispatchQueue.main.async {                    
                        self?.budgetings = returnedBudgeting
                    }
                }
                .store(in: &cancellables)
        }
        
        private func loadBudgetings() async {
            try? await dataService.getAll()
        }
    }
}
