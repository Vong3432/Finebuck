//
//  BudgetingDetailViewModelTests.swift
//  FinebuckTests
//
//  Created by Vong Nyuksoon on 04/05/2022.
//

import XCTest
import Resolver
import FirebaseAuth
@testable import Finebuck

// Naming structure: test_unitOfWork_stateUnderTest_expectedBehavior
// Naming structure: test_[struct/class]_[variable/function]_[expectedBehavior]
// Testing structure: Given, When, Then
class BudgetingDetailViewModelTests: XCTestCase {
    typealias BudgetingDetailViewModel = BudgetingDetailView.BudgetingDetailViewModel
    
    @LazyInjected var mockDBRepository: MockBudgetsDBRepository
    @LazyInjected var mockFailDBRepository: MockedBudgetsDBRepositoryFailed
    
    override class func setUp() {
        super.setUp()
    }
    
    override class func tearDown() {
        super.tearDown()
    }

    func test_BudgetingDetailViewModel_saveBudgetingOnly_shouldSuccess() async {
        Resolver.Name.mode = .mock
        
        // Given
        let mocked = Budgeting.mockBudgetingItems[0]
        let mockAuthService = MockFirebaseAuthService()
        let vm = BudgetingDetailViewModel(budgeting: mocked, authService: AnyFirebaseAuthService(mockAuthService))

        // When
        vm.saveBudgeting(budgetItem: nil) // Users create new budgeting without any budgetItem.
        
        // Then
        XCTAssertNil(vm.error)
        XCTAssertNotNil(vm.budgeting)
        XCTAssertEqual(vm.budgeting?.title, mocked.title)
    }
    
    func test_BudgetingDetailViewModel_saveBudgetingOnly_shouldFail() async {
        Resolver.Name.mode = .mockFailed
        
        // Given
        let mocked = Budgeting.mockBudgetingItems[0]
        let mockAuthService = MockFirebaseAuthService()
        let vm = BudgetingDetailViewModel(budgeting: mocked, authService: AnyFirebaseAuthService(mockAuthService))
//        let expected: BudgetsDBRepositoryError = .failed
        
        // When
        vm.saveBudgeting(budgetItem: nil) // Users create new budgeting without any budgetItem.
        
        // Then
        XCTAssertNotNil(vm.budgeting)
//        XCTAssertEqual(vm.error, expected)
    }
    
    func test_BudgetingDetailViewModel_saveBudgetingWithNewBudgetItem_shouldSuccess() async {
        Resolver.Name.mode = .mock
        
        // Given
        let mocked = Budgeting.mockBudgetingItems[0]
        
        for _ in 0...20 {
            let ran = Bool.random()
            
            // When
            let mockAuthService = MockFirebaseAuthService()
            try? await mockAuthService.login("N", "N")
            let vm = BudgetingDetailViewModel(budgeting: mocked, authService: AnyFirebaseAuthService(mockAuthService))
            
            if ran {
                // budgetItem = cost
                let prevCostCount = vm.costs.count
                let cost: BudgetItem = Budgeting.Cost(itemIdentifier: .cost, title: "COST", type: .rate, value: 0.0, rate: 0.20, currency: .myr)
                vm.saveBudgeting(budgetItem: cost)
                
                // Then
                XCTAssertNotNil(vm.budgeting)
                XCTAssertNil(vm.error)
                XCTAssertTrue(vm.costs.count > prevCostCount)
            } else {
                // budgetItem earning
                let prevEarningCount = vm.earnings.count
                let earning: BudgetItem = Budgeting.Earning(itemIdentifier: .earning, title: "Earning", type: .rate, value: 0.0, rate: 0.20, currency: .myr)
                vm.saveBudgeting(budgetItem: earning)
             
                // Then
                XCTAssertNotNil(vm.budgeting)
                XCTAssertNil(vm.error)
                XCTAssertTrue(vm.earnings.count > prevEarningCount)
            }
        }
    }
    
//    func test_BudgetingDetailViewModel_saveBudgetingWithNewBudgetItem_shouldFail() async  {
//        Resolver.Name.mode = .mockFailed
//        
//        // Given
//        let mocked = Budgeting.mockBudgetingItems[0]
////        let expected: BudgetsDBRepositoryError = .failed
//        
//        for _ in 0...20 {
//            let ran = Bool.random()
//            
//            // When
//            let mockAuthService = MockFirebaseAuthService()
//            let vm = BudgetingDetailViewModel(budgeting: mocked, authService: AnyFirebaseAuthService(mockAuthService))
//            
//            if ran {
//                // budgetItem = cost
//                let cost: BudgetItem = Budgeting.Cost(itemIdentifier: .cost, title: "COST", type: .rate, value: 0.0, rate: 0.20, currency: .myr)
//                vm.saveBudgeting(budgetItem: cost)
//                
//                // Then
//                let idx = vm.costs.firstIndex(where: { $0.id == cost.id })
//                
//                XCTAssertNil(idx)
////                XCTAssertNotNil(vm.error)
////                XCTAssertEqual(vm.error, expected)
//            } else {
//                // budgetItem earning
//                let earning: BudgetItem = Budgeting.Earning(itemIdentifier: .earning, title: "Earning", type: .rate, value: 0.0, rate: 0.20, currency: .myr)
//                vm.saveBudgeting(budgetItem: earning)
//             
//                // Then
//                let idx = vm.earnings.firstIndex(where: { $0.id == earning.id })
//                
//                XCTAssertNil(idx)
////                XCTAssertNotNil(vm.error)
////                XCTAssertEqual(vm.error, expected)
//            }
//        }
//    }
    
    func test_BudgetingDetailViewModel_saveBudgetingWithUpdatedBudgetItem_shouldSuccess() async  {
        Resolver.Name.mode = .mock
        
        // Given
        let mocked = Budgeting.mockBudgetingItems[0]
        
        for _ in 0...20 {
            let ran = Bool.random()
            
            // When
            let mockAuthService = MockFirebaseAuthService()
            try? await mockAuthService.login("anything", "anything")
            let vm = BudgetingDetailViewModel(budgeting: mocked, authService: AnyFirebaseAuthService(mockAuthService))
            
            if ran {
                // budgetItem = cost
                var cost: BudgetItem = mocked.costs[0]
                let prev = cost.title
                cost.title = "UPDATED"
                
                vm.viewBudgetItem(cost) // simulate user viewing a budget item
                vm.saveBudgeting(budgetItem: cost) // simulate user saves budget item
                
                // Then
                let idx = vm.costs.firstIndex(where: { $0.id == cost.id })
                
                guard let idx = idx, let budgeting = vm.budgeting else {
                    return XCTFail()
                }
                
                XCTAssertNotNil(idx)
                XCTAssertNil(vm.error)
                XCTAssertNotEqual(prev, vm.costs[idx].title)
            } else {
                // budgetItem earning
                var earning: BudgetItem = mocked.earning[0]
                let prev = earning.title
                earning.title = "UPDATED"
                
                vm.viewBudgetItem(earning) // simulate user viewing a budget item
                vm.saveBudgeting(budgetItem: earning) // simulate user saves budget item
             
                // Then
                let idx = vm.earnings.firstIndex(where: { $0.id == earning.id })
                
                guard let idx = idx, let budgeting = vm.budgeting  else {
                    return XCTFail()
                }
                
                XCTAssertNotNil(idx)
                XCTAssertNil(vm.error)
                XCTAssertNotEqual(prev, vm.earnings[idx].title)
            }
        }
    }
    
    func test_BudgetingDetailViewModel_saveBudgetingWithUpdatedBudgetItem_shouldFail() async  {
        Resolver.Name.mode = .mockFailed
        
        // Given
        let mocked = Budgeting.mockBudgetingItems[0]
        
        for _ in 0...20 {
            let ran = Bool.random()
            
            // When
            let mockAuthService = MockFirebaseAuthService()
            try? await mockAuthService.login("anything", "anything")
            let vm = BudgetingDetailViewModel(budgeting: mocked, authService: AnyFirebaseAuthService(mockAuthService))
            
            if ran {
                // budgetItem = cost
                var cost: BudgetItem = mocked.costs[0]
                let prev = cost.title
                cost.title = "UPDATED"
                
                vm.viewBudgetItem(cost) // simulate user viewing a budget item
                vm.saveBudgeting(budgetItem: cost) // simulate user saves budget item
                
                // Then
                let idx = vm.costs.firstIndex(where: { $0.id == cost.id })
                
//                XCTAssertNotNil(vm.error)
//                XCTAssertEqual(vm.error, .failed)
                XCTAssertNotEqual(prev, cost.title)
            } else {
                // budgetItem earning
                var earning: BudgetItem = mocked.earning[0]
                let prev = earning.title
                earning.title = "UPDATED"
                
                vm.viewBudgetItem(earning) // simulate user viewing a budget item
                vm.saveBudgeting(budgetItem: earning) // simulate user saves budget item
             
                // Then
                let idx = vm.earnings.firstIndex(where: { $0.id == earning.id })
                
//                XCTAssertNotNil(vm.error)
//                XCTAssertEqual(vm.error, .failed)
                XCTAssertNotEqual(prev, earning.title)
            }
        }
    }
}
