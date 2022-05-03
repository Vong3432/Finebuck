//
//  MockBudgetsDBRepository.swift
//  FinebuckTests
//
//  Created by Vong Nyuksoon on 03/05/2022.
//

import Foundation
import Combine
@testable import Finebuck

final class MockedBudgetsDBRepositoryFailed: BudgetsDBRepositoryProtocol {
    func getAll(completion: @escaping (Result<[Budgeting], BudgetsDBRepositoryError>) -> Void) {
        completion(.failure(.failed))
    }
    
    func save(_ budgeting: Budgeting, completion: @escaping (Result<Budgeting, BudgetsDBRepositoryError>) -> Void) {
        completion(.failure(.failed))
    }
    
    func update(_ targetBudgeting: Budgeting, with: Budgeting, completion: @escaping (Result<Budgeting, BudgetsDBRepositoryError>) -> Void) {
        completion(.failure(.noResult))
    }
    
    func delete(targetBudgeting: Budgeting, completion: @escaping (Result<Void, BudgetsDBRepositoryError>) -> Void) {
        completion(.failure(.failed))
    }
    
    func get(_ budgeting: Budgeting, completion: @escaping (Result<Budgeting?, BudgetsDBRepositoryError>) -> Void) {
        completion(.failure(.noResult))
    }
}

final class MockBudgetsDBRepository: BudgetsDBRepositoryProtocol {
    func getAll(completion: @escaping (Result<[Budgeting], BudgetsDBRepositoryError>) -> Void) {
        let mocked = Budgeting.mockBudgetingItems
        completion(.success(mocked))
    }
    
    func save(_ budgeting: Budgeting, completion: @escaping (Result<Budgeting, BudgetsDBRepositoryError>) -> Void) {
        completion(.success(budgeting))
    }
    
    func update(_ targetBudgeting: Budgeting, with: Budgeting, completion: @escaping (Result<Budgeting, BudgetsDBRepositoryError>) -> Void) {
        completion(.success(with))
    }
    
    func delete(targetBudgeting: Budgeting, completion: @escaping (Result<Void, BudgetsDBRepositoryError>) -> Void) {
        completion(.success(Void()))
    }
    
    func get(_ budgeting: Budgeting, completion: @escaping (Result<Budgeting?, BudgetsDBRepositoryError>) -> Void) {
        completion(.success(budgeting))
    }
    
}
