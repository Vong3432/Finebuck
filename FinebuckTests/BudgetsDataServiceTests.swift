//
//  BudgetsDataServiceTests.swift
//  FinebuckTests
//
//  Created by Vong Nyuksoon on 03/05/2022.
//

import XCTest
@testable import Finebuck

// Naming structure: test_unitOfWork_stateUnderTest_expectedBehavior
// Naming structure: test_[struct/class]_[variable/function]_[expectedBehavior]
// Testing structure: Given, When, Then
class BudgetsDataServiceTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    func test_BudgetsDataService_loadAll_shouldSuccess() {
        // Given
        let mockedRepository = MockBudgetsDBRepository()
        let service = BudgetsDataService(repository: mockedRepository)
        
        // When
        service.loadAll()
        
        // Then
        XCTAssertTrue(service.data.count > 0)
    }
    
    func test_BudgetsDataService_loadAll_shouldFail() {
        // Given
        let mockedRepository = MockedBudgetsDBRepositoryFailed()
        let service = BudgetsDataService(repository: mockedRepository)
        let expected: BudgetsDBRepositoryError = .failed
        
        // When
        service.loadAll()
        
        // Then
        XCTAssertTrue(service.error != nil)
        XCTAssertEqual(service.error, expected)
    }
    
    func test_BudgetsDataService_loadOne_shouldSuccess() {
        // Given
        let mockedRepository = MockBudgetsDBRepository()
        let service = BudgetsDataService(repository: mockedRepository)
        let find = Budgeting.mockBudgetingItems[0]
        
        // When
        service.loadOne(of: find)
        
        // Then
        XCTAssertNotNil(service.loadedSingleData)
    }
    
    func test_BudgetsDataService_loadOne_shouldFailWhenNoResult() {
        // Given
        let mockedRepository = MockedBudgetsDBRepositoryFailed()
        let service = BudgetsDataService(repository: mockedRepository)
        let expected: BudgetsDBRepositoryError = .noResult
        let find = Budgeting.mockBudgetingItems[0]
        
        // When
        service.loadOne(of: find)
        
        // Then
        XCTAssertTrue(service.error != nil)
        XCTAssertEqual(service.error, expected)
    }
    
    func test_BudgetsDataService_save_shouldSuccess() {
        // Given
        let mockedRepository = MockBudgetsDBRepository()
        let service = BudgetsDataService(repository: mockedRepository)
        let previous = service.data
        let find = Budgeting.mockBudgetingItems[0]
        
        // When
        service.save(with: find)
        let after = service.data
        
        // Then
        XCTAssertTrue(after.count == (previous.count + 1)) // make sure item is saved into data
    }
    
    func test_BudgetsDataService_save_shouldFail() {
        // Given
        let mockedRepository = MockedBudgetsDBRepositoryFailed()
        let service = BudgetsDataService(repository: mockedRepository)
        let expected: BudgetsDBRepositoryError = .failed
        let find = Budgeting.mockBudgetingItems[0]
        
        // When
        service.save(with: find)
        
        // Then
        XCTAssertTrue(service.error != nil)
        XCTAssertEqual(service.error, expected)
    }
    
    func test_BudgetsDataService_update_shouldSuccess() {
        // Given
        let mockedRepository = MockBudgetsDBRepository()
        let service = BudgetsDataService(repository: mockedRepository)
        let find = Budgeting.mockBudgetingItems[0]
        let new = Budgeting.mockBudgetingItems[1]
        
        // When
        service.loadAll()
        service.update(for: find, with: new)
        
        let newidx = service.data.firstIndex { $0.id == new.id }
        
        // Then
        XCTAssertNotNil(newidx)
    }
    
    func test_BudgetsDataService_update_shouldFail() {
        // Given
        let mockedRepository = MockedBudgetsDBRepositoryFailed()
        let service = BudgetsDataService(repository: mockedRepository)
        let expected: BudgetsDBRepositoryError = .noResult
        let find = Budgeting.mockBudgetingItems[0]
        let new = Budgeting.mockBudgetingItems[1]
        
        // When
        service.update(for: find, with: new)
        
        // Then
        XCTAssertTrue(service.error != nil)
        XCTAssertEqual(service.error, expected)
    }
    
    func test_BudgetsDataService_delete_shouldSuccess() {
        // Given
        let mockedRepository = MockBudgetsDBRepository()
        let service = BudgetsDataService(repository: mockedRepository)
        let find = Budgeting.mockBudgetingItems[0]
        
        // When
        service.loadAll()
        let previous = service.data
        service.delete(for: find)
        let after = service.data
        
        let idx = service.data.firstIndex { $0.id == find.id }
        
        // Then
        XCTAssertNil(idx)
        XCTAssertTrue(after.count == (previous.count - 1)) // make sure item is removed from data
    }
    
    func test_BudgetsDataService_delete_shouldFail() {
        // Given
        let mockedRepository = MockedBudgetsDBRepositoryFailed()
        let service = BudgetsDataService(repository: mockedRepository)
        let expected: BudgetsDBRepositoryError = .failed
        let find = Budgeting.mockBudgetingItems[0]
        
        // When
        service.delete(for: find)
        
        // Then
        XCTAssertTrue(service.error != nil)
        XCTAssertEqual(service.error, expected)
    }
}
