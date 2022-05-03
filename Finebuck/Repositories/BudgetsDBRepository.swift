//
//  BudgetsDBRepository.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 03/05/2022.
//

import Foundation
import Combine


enum BudgetsDBRepositoryError: Error {
    case failed, noResult, notAuthenticated
}

protocol BudgetsDBRepositoryProtocol {
    func save(_ budgeting: Budgeting, completion: @escaping (Result<Budgeting, BudgetsDBRepositoryError>) -> Void)
    func update(_ targetBudgeting: Budgeting, with: Budgeting, completion: @escaping(Result<Budgeting, BudgetsDBRepositoryError>) -> Void)
    func delete(targetBudgeting: Budgeting, completion: @escaping (Result<Void, BudgetsDBRepositoryError>) -> Void)
    func get(_ budgeting: Budgeting, completion: @escaping (Result<Budgeting?, BudgetsDBRepositoryError>) -> Void)
    func getAll(completion: @escaping (Result<[Budgeting], BudgetsDBRepositoryError>) -> Void) -> Void
}

final class BudgetsDBRepository: BudgetsDBRepositoryProtocol {
    private let networkingManager = NetworkingManager()
    
    func save(_ budgeting: Budgeting, completion: @escaping (Result<Budgeting, BudgetsDBRepositoryError>) -> Void) {
        
    }
    
    func update(_ targetBudgeting: Budgeting, with: Budgeting, completion: @escaping (Result<Budgeting, BudgetsDBRepositoryError>) -> Void) {
        
    }
    
    func delete(targetBudgeting: Budgeting, completion: @escaping (Result<Void, BudgetsDBRepositoryError>) -> Void) {
        
    }
    
    func get(_ budgeting: Budgeting, completion: @escaping (Result<Budgeting?, BudgetsDBRepositoryError>) -> Void) {
        
    }
    
    func getAll(completion: @escaping (Result<[Budgeting], BudgetsDBRepositoryError>) -> Void) {
        
    }
    
    
}
