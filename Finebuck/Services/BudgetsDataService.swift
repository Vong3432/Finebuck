//
//  BudgetsDataService.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 03/05/2022.
//

import Foundation
import Combine

protocol BudgetsDataServiceProtocol {
    /// External subscribers from other classes should listen to this property to get changes
    var data: [Budgeting] { get }
    var dataPublished: Published<[Budgeting]> { get }
    var dataPublisher: Published<[Budgeting]>.Publisher { get }
    
    /// External subscribers from other classes should listen to this property to get changes
    var loadedSingleData: Budgeting? { get }
    var loadedSingleDataPublished: Published<Budgeting?> { get }
    var loadedSingleDataPublisher: Published<Budgeting?>.Publisher { get }
    
    var isLoading: Bool { get }
    var error: BudgetsDBRepositoryError? { get }
    
    var repository: BudgetsDBRepositoryProtocol { get }
    
    func loadAll() -> Void
    func loadOne(of _: Budgeting) -> Void
    func save(with _: Budgeting) -> Void
    func update(for _: Budgeting, with _: Budgeting) -> Void
    func delete(for _: Budgeting) -> Void
}

final class BudgetsDataService: BudgetsDataServiceProtocol {
    
    @Published private(set) var data = [Budgeting]()
    var dataPublished: Published<[Budgeting]> { _data}
    var dataPublisher: Published<[Budgeting]>.Publisher { $data }
    
    @Published private(set) var loadedSingleData: Budgeting? = nil
    var loadedSingleDataPublished: Published<Budgeting?> { _loadedSingleData}
    var loadedSingleDataPublisher: Published<Budgeting?>.Publisher { $loadedSingleData }
    
    @Published private(set) var isLoading = false
    @Published private(set) var error: BudgetsDBRepositoryError? = nil
    
    internal let repository: BudgetsDBRepositoryProtocol
    
    init(repository: BudgetsDBRepositoryProtocol) {
        self.repository = repository
    }
    
    func loadAll() {
        repository.getAll { [weak self] result in
            switch result {
            case .failure(let error):
                self?.error = error
            case .success(let budgetings):
                self?.data = budgetings
            }
        }
    }
    
    func loadOne(of budgeting: Budgeting) {
        repository.get(budgeting) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.error = error
            case .success(let budgeting):
                self?.loadedSingleData = budgeting
            }
        }
    }
    
    func save(with budgeting: Budgeting) {
        repository.save(budgeting) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.error = error
            case .success(let budgeting):
                self?.data.append(budgeting)
            }
        }
    }
    
    func update(for targetBudgeting: Budgeting, with newBudgeting: Budgeting) {
        repository.update(targetBudgeting, with: newBudgeting) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.error = error
            case .success(let budgeting):
                guard let targetIdx = self?.data.firstIndex(where: { $0.id == targetBudgeting.id} ) else { return }
                self?.data[targetIdx] = budgeting
            }
        }
    }
    
    func delete(for targetBudgeting: Budgeting) {
        repository.delete(targetBudgeting: targetBudgeting) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.error = error
            case .success(_):
                guard let targetIdx = self?.data.firstIndex(where: { $0.id == targetBudgeting.id} ) else { return }
                self?.data.remove(at: targetIdx)
            }
        }
    }
    
    
}
