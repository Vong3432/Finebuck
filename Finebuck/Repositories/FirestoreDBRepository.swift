//
//  FirestoreDBRepository.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 15/08/2022.
//

import FirebaseFirestore
import Combine
import Foundation

enum FirestoreDBRepositoryError: LocalizedError {
    case failed, noResult, notAuthenticated, unexpect
    
    var errorDescription: String? {
        switch self {
        case .failed:
            return "Failed to perform this action"
        case .noResult:
            return "No result"
        case .notAuthenticated:
            return "Unauthenticated"
        case .unexpect:
            return "Unexpected error occured. Please try again."
        }
    }
}

protocol FirestoreDBRepositoryProtocol {
    associatedtype ItemType
    
    var store: Firestore { get }
    var path: String { get }
    var listener: ListenerRegistration? { get set }
    
    var items: [ItemType] { get }
    var itemsPublished: Published<[ItemType]> { get }
    var itemsPublisher: Published<[ItemType]>.Publisher { get }
    
    func save(_ item: ItemType) async throws -> ItemType?
    func update(_ item: ItemType, with: [String: Any]) async throws -> Void
    func updateMultiple(_ items: [ItemType], newDataArr: [[String: Any]]) async throws -> Void
    func delete(item: ItemType) async throws -> Void
    func get(_ item: ItemType) async throws -> ItemType?
    func getAll(fromUserId: String) async throws -> Void
//    func loadMore(fromUserId: String) async throws -> Void
    
    func reset() -> Void
    func removeListeners() -> Void
}

// MARK: - Type Eraser
class AnyFirestoreDBRepository<T>: FirestoreDBRepositoryProtocol, ObservableObject {
    
    var store: Firestore
    var path: String
    var listener: ListenerRegistration?
    
    @Published var items: [T]
    var itemsPublished: Published<[T]> { _items }
    var itemsPublisher: Published<[T]>.Publisher { $items }
    
    private var cancellable = Set<AnyCancellable>()
    
    init<U: FirestoreDBRepositoryProtocol>(_ service: U) where U.ItemType == T {
        store = service.store
        path = service.path
        listener = service.listener
        items = service.items
        
        _save = service.save(_:)
        _update = service.update(_:with:)
        _updateMultiple = service.updateMultiple(_:newDataArr:)
        _delete = service.delete(item:)
        _get = service.get(_:)
        _getAll = service.getAll(fromUserId:)
//        _loadMore = service.loadMore(fromUserId:)
        _reset = service.reset
        _removeListeners = service.removeListeners
        
        service.itemsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
            self?.items = items
        }.store(in: &cancellable)
    }
    
    // MARK: - Signatures
    private let _save: (_ item: T) async throws -> T?
    private let _update: (_ item: T, _ with: [String: Any]) async throws -> Void
    private let _updateMultiple: (_ items: [T], _ newDataArr: [[String: Any]]) async throws -> Void
    private let _delete: (_ item: T) async throws -> Void
    private let _get: (_ item: T) async throws -> T?
    private let _getAll: (_ fromUserId: String) async throws -> Void
//    private let _loadMore: (_ fromUserId: String) async throws -> Void
    
    private let _reset: () -> Void
    private let _removeListeners: () -> Void
    
    func save(_ item: T) async throws -> T? {
        return try await _save(item)
    }
    
    func update(_ item: T, with: [String : Any]) async throws {
        try await _update(item, with)
    }
    
    func updateMultiple(_ items: [T], newDataArr: [[String : Any]]) async throws {
        try await _updateMultiple(items, newDataArr)
    }
    
    func delete(item: T) async throws {
        try await _delete(item)
    }
    
    func get(_ item: T) async throws -> T? {
        return try await _get(item)
    }
    
    func getAll(fromUserId: String) async throws {
        try await _getAll(fromUserId)
    }
    
    func reset() {
        _reset()
    }
    
    func removeListeners() {
        _removeListeners()
    }
}
