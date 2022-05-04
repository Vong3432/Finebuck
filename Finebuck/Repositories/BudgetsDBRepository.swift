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
    func save(_ budgeting: Budgeting) async throws -> Budgeting
    func update(_ targetBudgeting: Budgeting, with: Budgeting) async throws -> Budgeting
    func delete(targetBudgeting: Budgeting) async throws -> Void
    func get(_ budgeting: Budgeting) async throws -> Budgeting?
    func getAll() async throws -> [Budgeting]
//    func save(_ budgeting: Budgeting, completion: @escaping (Result<Budgeting, BudgetsDBRepositoryError>) -> Void)
//    func update(_ targetBudgeting: Budgeting, with: Budgeting, completion: @escaping(Result<Budgeting, BudgetsDBRepositoryError>) -> Void)
//    func delete(targetBudgeting: Budgeting, completion: @escaping (Result<Void, BudgetsDBRepositoryError>) -> Void)
//    func get(_ budgeting: Budgeting, completion: @escaping (Result<Budgeting?, BudgetsDBRepositoryError>) -> Void)
//    func getAll(completion: @escaping (Result<[Budgeting], BudgetsDBRepositoryError>) -> Void) -> Void
}

final class BudgetsDBRepository: BudgetsDBRepositoryProtocol {

    private let networkingManager = NetworkingManager()

    func save(_ budgeting: Budgeting) async throws -> Budgeting {
        return budgeting
    }
    
    func update(_ targetBudgeting: Budgeting, with updatedBudgeting: Budgeting) async -> Budgeting {
        return updatedBudgeting
    }
    
    func delete(targetBudgeting: Budgeting) async {
        
    }
    
    func get(_ budgeting: Budgeting) async -> Budgeting? {
        return nil
    }
    
    func getAll() async -> [Budgeting] {
        return []
    }
}
