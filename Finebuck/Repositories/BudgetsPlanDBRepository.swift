//
//  BudgetsPlanDBRepository.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 04/05/2022.
//

import Foundation

// MARK: - Is this file required (?)

enum BudgetsPlanDBRepositoryError: Error {
    case failed, noResult, notAuthenticated
}

protocol BudgetsPlanDBRepositoryProtocol {
    func save(_ item: BudgetItem, completion: @escaping (Result<BudgetItem, BudgetsPlanDBRepositoryError>) -> Void)
    func update(_ targetBudgetItem: BudgetItem, with: BudgetItem, completion: @escaping(Result<BudgetItem, BudgetsPlanDBRepositoryError>) -> Void)
    func delete(targetBudgetItem: BudgetItem, completion: @escaping (Result<Void, BudgetsPlanDBRepositoryError>) -> Void)
    func get(_ item: BudgetItem, completion: @escaping (Result<BudgetItem?, BudgetsPlanDBRepositoryError>) -> Void)
    func getAll(from budgeting: Budgeting, completion: @escaping (Result<[BudgetItem], BudgetsPlanDBRepositoryError>) -> Void) -> Void
}

final class BudgetsPlanDBRepository: BudgetsPlanDBRepositoryProtocol {
    private let networkingManager = NetworkingManager()
    
    func save(_ item: BudgetItem, completion: @escaping (Result<BudgetItem, BudgetsPlanDBRepositoryError>) -> Void) {
        
    }
    
    func update(_ targetBudgetItem: BudgetItem, with: BudgetItem, completion: @escaping (Result<BudgetItem, BudgetsPlanDBRepositoryError>) -> Void) {
        
    }
    
    func delete(targetBudgetItem: BudgetItem, completion: @escaping (Result<Void, BudgetsPlanDBRepositoryError>) -> Void) {
        
    }
    
    func get(_ item: BudgetItem, completion: @escaping (Result<BudgetItem?, BudgetsPlanDBRepositoryError>) -> Void) {
        
    }
    
    func getAll(from budgeting: Budgeting ,completion: @escaping (Result<[BudgetItem], BudgetsPlanDBRepositoryError>) -> Void) {
        
    }
    
    
}
