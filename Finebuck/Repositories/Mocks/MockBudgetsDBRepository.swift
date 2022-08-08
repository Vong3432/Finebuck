//
//  MockBudgetsDBRepository.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 05/05/2022.
//

import Foundation
import Combine

final class MockedBudgetsDBRepositoryFailed: BudgetsDBRepositoryProtocol {
    func removeListeners() {
        
    }
    
    @Published var budgetings: [Budgeting] = []
    var budgetingsPublished: Published<[Budgeting]> { _budgetings }
    var budgetingsPublisher: Published<[Budgeting]>.Publisher { $budgetings }
    
    func save(_ budgeting: Budgeting) async throws -> Budgeting? {
        throw BudgetsDBRepositoryError.failed
    }
    
    func update(_ targetBudgeting: Budgeting, with: Budgeting) async throws -> Budgeting {
        throw BudgetsDBRepositoryError.failed
    }
    
    func delete(targetBudgeting: Budgeting) async throws {
        throw BudgetsDBRepositoryError.failed
    }
    
    func get(_ budgeting: Budgeting) async throws -> Budgeting? {
        throw BudgetsDBRepositoryError.noResult
    }
    
    func getAll() async throws {
        throw BudgetsDBRepositoryError.noResult
    }
    
}

final class MockBudgetsDBRepository: BudgetsDBRepositoryProtocol {
    @Published var budgetings: [Budgeting] = []
    var budgetingsPublished: Published<[Budgeting]> { _budgetings }
    var budgetingsPublisher: Published<[Budgeting]>.Publisher { $budgetings }
    
    func save(_ budgeting: Budgeting) async throws -> Budgeting? {
        return budgeting
    }
    
    func update(_ targetBudgeting: Budgeting, with: Budgeting) async throws -> Budgeting {
        return with
    }
    
    func delete(targetBudgeting: Budgeting) async throws {
        return
    }
    
    func get(_ budgeting: Budgeting) async throws -> Budgeting? {
        return budgeting
    }
    
    func getAll() async throws -> Void {
        self.budgetings = Budgeting.mockBudgetingItems
    }
    
    
    func removeListeners() {
        
    }
    
}
