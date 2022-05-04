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
    func save(_ budgeting: Budgeting) async throws -> Budgeting {
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
    
    func getAll() async throws -> [Budgeting] {
        throw BudgetsDBRepositoryError.noResult
    }
    
    
}

final class MockBudgetsDBRepository: BudgetsDBRepositoryProtocol {
    func save(_ budgeting: Budgeting) async throws -> Budgeting {
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
    
    func getAll() async throws -> [Budgeting] {
        let mocked = Budgeting.mockBudgetingItems
        return mocked
    }
    
}
