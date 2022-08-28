//
//  MockBudgetsDBRepository.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 05/05/2022.
//

import Foundation
import Combine
import FirebaseFirestore

final class MockedBudgetsDBRepositoryFailed: FirestoreDBRepositoryProtocol {
    var store: Firestore = Firestore.firestore()
    var path: String = ""
    var listener: ListenerRegistration?
    
    func updateMultiple(_ items: [Budgeting], newDataArr: [[String : Any]]) async throws {
        throw FirestoreDBRepositoryError.failed
    }
    
    func reset() {
        
    }
    
    func removeListeners() {
        
    }
    
    @Published var items: [Budgeting] = []
    var itemsPublished: Published<[Budgeting]> { _items }
    var itemsPublisher: Published<[Budgeting]>.Publisher { $items }
    
    func save(_ budgeting: Budgeting) async throws -> Budgeting? {
        throw FirestoreDBRepositoryError.failed
    }
    
    func update(_ targetBudgeting: Budgeting, with: [String: Any]) async throws -> Void {
        throw FirestoreDBRepositoryError.failed
    }
    
    func delete(item targetBudgeting: Budgeting) async throws {
        throw FirestoreDBRepositoryError.failed
    }
    
    func get(_ budgeting: Budgeting) async throws -> Budgeting? {
        throw FirestoreDBRepositoryError.noResult
    }
    
    func getAll(fromUserId: String) async throws {
        throw FirestoreDBRepositoryError.noResult
    }
    
    func loadMore(fromUserId: String) async throws {
        
    }
}

final class MockBudgetsDBRepository: FirestoreDBRepositoryProtocol {
    var store: Firestore = Firestore.firestore()
    var path: String = ""
    var listener: ListenerRegistration?
    
    @Published var items: [Budgeting] = []
    var itemsPublished: Published<[Budgeting]> { _items }
    var itemsPublisher: Published<[Budgeting]>.Publisher { $items }
    
    func save(_ budgeting: Budgeting) async throws -> Budgeting? {
        return budgeting
    }
    
    func update(_ targetBudgeting: Budgeting, with: [String: Any]) async throws -> Void {
        
    }
    
    func updateMultiple(_ items: [Budgeting], newDataArr: [[String : Any]]) async throws {
        
    }
    
    func delete(item targetBudgeting: Budgeting) async throws {
        return
    }
    
    func get(_ budgeting: Budgeting) async throws -> Budgeting? {
        return budgeting
    }
    
    func getAll(fromUserId: String) async throws -> Void {
        self.items = Budgeting.mockBudgetingItems
    }
    
    func reset() {
        
    }
    
    func removeListeners() {
        
    }
    
    func loadMore(fromUserId: String) async throws {
        
    }
    
}
