//
//  BudgetPlanDetailFormViewModelTests.swift
//  FinebuckTests
//
//  Created by Vong Nyuksoon on 03/05/2022.
//

import XCTest
@testable import Finebuck

// Naming structure: test_unitOfWork_stateUnderTest_expectedBehavior
// Naming structure: test_[struct/class]_[variable/function]_[expectedBehavior]
// Testing structure: Given, When, Then
class BudgetPlanDetailFormViewModelTests: XCTestCase {
    
    typealias BudgetPlanDetailFormViewModel = BudgetPlanDetailFormView.BudgetPlanDetailFormViewModel

    override class func setUp() {
        super.setUp()
    }
    
    func test_BudgetPlanDetailFormViewModel_preset_shouldSetData() {
        // Given
        let mockedDataRepository = MockBudgetsDBRepository()
        let mockedDataService = BudgetsDataService(repository: mockedDataRepository)
        let item = Budgeting.mockBudgetingItems[0].costs[0]
        
        // When
        let vm = BudgetPlanDetailFormViewModel(budgetItem: item, dataService: mockedDataService)
        
        // Then
        XCTAssertEqual(vm.calculationItem?.id, item.id)
        XCTAssertEqual(vm.label, item.title)
        XCTAssertEqual(vm.amount, item.value)
        XCTAssertEqual(vm.rate, item.rate)
        XCTAssertEqual(vm.itemIdentifier, item.itemIdentifier)
        XCTAssertEqual(vm.budgetCalculateType, item.type)
        XCTAssertEqual(vm.currency.id, item.currency.id)
    }
    
    func test_BudgetPlanDetailFormViewModel_switchCalculateType_shouldChangeToFixed() {
        // Given
        let mockedDataRepository = MockBudgetsDBRepository()
        let mockedDataService = BudgetsDataService(repository: mockedDataRepository)
        let item = Budgeting.mockBudgetingItems[0].costs[0]
        let vm = BudgetPlanDetailFormViewModel(budgetItem: item, dataService: mockedDataService)
        let expected: Budgeting.CalculateType = .fixed
        
        // When
        vm.switchCalculateType(to: expected)
        
        // Then
        XCTAssertEqual(vm.budgetCalculateType, expected)
        // hide rate field, show fixed field
        XCTAssertTrue(vm.rateFieldOpacity == 0)
        XCTAssertTrue(vm.fixedAmountFieldOpacity == 1)
    }
    
    func test_BudgetPlanDetailFormViewModel_switchCalculateType_shouldChangeToRate() {
        // Given
        let mockedDataRepository = MockBudgetsDBRepository()
        let mockedDataService = BudgetsDataService(repository: mockedDataRepository)
        let item = Budgeting.mockBudgetingItems[0].costs[0]
        let vm = BudgetPlanDetailFormViewModel(budgetItem: item, dataService: mockedDataService)
        let expected: Budgeting.CalculateType = .rate
        
        // When
        vm.switchCalculateType(to: expected)
        
        // Then
        XCTAssertEqual(vm.budgetCalculateType, expected)
        // hide fixed field, show rate field
        XCTAssertTrue(vm.rateFieldOpacity == 1)
        XCTAssertTrue(vm.fixedAmountFieldOpacity == 0)
    }
    
    func test_BudgetPlanDetailFormViewModel_switchFormType_shouldChangesSuccessfully() {
        // Given
        let mockedDataRepository = MockBudgetsDBRepository()
        let mockedDataService = BudgetsDataService(repository: mockedDataRepository)
        let item = Budgeting.mockBudgetingItems[0].costs[0]
        let vm = BudgetPlanDetailFormViewModel(budgetItem: item, dataService: mockedDataService)
        let expected: ItemIdentifier = .earning
        
        // When
        vm.switchFormType(to: expected)
        
        // Then
        XCTAssertEqual(vm.itemIdentifier, expected)
    }

    func test_BudgetPlanDetailFormViewModel_switchCurrencyType_shouldChangesSuccessfully() {
        // Given
        let mockedDataRepository = MockBudgetsDBRepository()
        let mockedDataService = BudgetsDataService(repository: mockedDataRepository)
        let item = Budgeting.mockBudgetingItems[0].costs[0]
        let vm = BudgetPlanDetailFormViewModel(budgetItem: item, dataService: mockedDataService)
        let expected: Currency = .myr
        
        // When
        vm.switchCurrencyType(to: expected)
        
        // Then
        XCTAssertEqual(vm.currency.id, expected.id)
    }
}

