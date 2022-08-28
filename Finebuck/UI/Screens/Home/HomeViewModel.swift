//
//  HomeViewModel.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 03/05/2022.
//

import Foundation
import Combine
import Resolver
import FirebaseAuth

extension HomeView {
    class HomeViewModel: ObservableObject {
        @Published var budgetings = [Budgeting]()
        @Published var isFetchingMore = false
        @Published var errorMsg: String?
        
        @Injected private(set) var dataService: AnyFirestoreDBRepository<Budgeting>
        private(set) var authService: AnyFirebaseAuthService<User>
        private var cancellables = Set<AnyCancellable>()
        
        
        init(authService: AnyFirebaseAuthService<User>) {
            self.authService = authService
            subscribe()
            loadBudgetings()
        }
        
        deinit {
            print("HomeVM deinit")
        }
        
        private func subscribe() {
            dataService.itemsPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] returnedBudgeting in
                    self?.budgetings = returnedBudgeting
                }
                .store(in: &cancellables)
        }
        
        func loadBudgetings() {
            guard let uid = authService.user?.uid else { return }
            self.errorMsg = nil
            
            Task {
                do {
                    // TODO: Test paginate delay, remove when needed
                    try await dataService.getAll(fromUserId: uid)
                    
                    await MainActor.run {
                        self.isFetchingMore = false
                    }
                    
                } catch let error {
                    handleError(error)
                }
            }
        }
        
        func loadMore() {
            errorMsg = nil
            isFetchingMore = true
            loadBudgetings()
        }
        
        func deleteBudgetPlan(for target: Budgeting) {
            Task {
                do {
                    try await dataService.delete(item: target)
                } catch let error {
                    handleError(error)
                }
            }
        }
        
        private func handleError(_ error: Error) {
            if let error = error as? FirestoreDBRepositoryError {
                print(error.localizedDescription)
                errorMsg = error.localizedDescription
            }
        }
    }
}
