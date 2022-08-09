//
//  BudgetsDBRepository.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 03/05/2022.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

/**
 FirebaseFirestoreSwift adds some cool functionalities to help you integrate Firestore with your models. It lets you convert Models into documents and documents into Models.
 */
import FirebaseFirestoreSwift

enum BudgetsDBRepositoryError: Error {
    case failed, noResult, notAuthenticated
}

protocol BudgetsDBRepositoryProtocol {
    var budgetings: [Budgeting] { get }
    var budgetingsPublished: Published<[Budgeting]> { get }
    var budgetingsPublisher: Published<[Budgeting]>.Publisher { get }
    
    func save(_ budgeting: Budgeting) async throws -> Budgeting?
    func update(_ targetBudgeting: Budgeting, with: [String: Any]) async throws -> Budgeting
    func delete(targetBudgeting: Budgeting) async throws -> Void
    func get(_ budgeting: Budgeting) async throws -> Budgeting?
    func getAll(fromUserId: String) async throws -> Void
    
    func reset() -> Void
    func removeListeners() -> Void
}

final class BudgetsDBRepository: BudgetsDBRepositoryProtocol, ObservableObject {
    
    
    @Published var budgetings = [Budgeting]()
    var budgetingsPublished: Published<[Budgeting]> { _budgetings }
    var budgetingsPublisher: Published<[Budgeting]>.Publisher { $budgetings }
    
    private let store = Firestore.firestore()
    private let path = "budgetings"
    var listener: ListenerRegistration?
    
    func save(_ budgeting: Budgeting) async throws -> Budgeting? {
        do {
            var newBudgeting = budgeting
            
            if newBudgeting.id == nil {
                let ref = try store.collection(path).addDocument(from: budgeting)
                newBudgeting = try await ref.getDocument(as: Budgeting.self)
            } else {
                try store.collection(path).document(budgeting.id!).setData(from: budgeting, merge: true)
            }
            
            return try await get(newBudgeting)
        } catch let error {
            debugPrint("Save budget err: \(error)")
            throw BudgetsDBRepositoryError.failed
        }
    }
    
    func update(_ targetBudgeting: Budgeting, with field: [String: Any]) async throws -> Budgeting {
//        do {
//            try await store
//                .collection(.firestoreBudgetingsPath)
//                .document(targetBudgeting.id!)
//                .updateData(field)
//
//            return try await get(targetBudgeting)
//        } catch {
//            print("Unable to update budget: \(error.localizedDescription).")
//            throw BudgetsDBRepositoryError.failed
//        }
        fatalError("Not implemented.")
    }
    
    func delete(targetBudgeting: Budgeting) async throws {
        do {
            try await store.collection(path).document(targetBudgeting.id!).delete()
        } catch {
            throw BudgetsDBRepositoryError.failed
        }
    }
    
    func get(_ budgeting: Budgeting) async throws -> Budgeting? {
        do {
            let budgetingRef = store.collection(path).document(budgeting.id!)
            let doc = try await budgetingRef.getDocument()
            let budgeting = try doc.data(as: Budgeting.self)
            
            return budgeting
        } catch {
            throw BudgetsDBRepositoryError.noResult
        }
    }
    
    func getAll(fromUserId: String) async throws -> Void {
        // Attach listener for first time.
        if listener == nil {
            listener = store.collection(path)
                .whereField("creatorUid", isEqualTo: fromUserId)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }

                    self.budgetings = snapshot?.documents.compactMap { document in
                        try? document.data(as: Budgeting.self)
                    } ?? []
                }
        }
        
        do {
            try await store.collection(path)
                .whereField("creatorUid", isEqualTo: fromUserId)
                .getDocuments()
        } catch {
            throw BudgetsDBRepositoryError.failed
        }
    }
    
    func reset() {
        budgetings = []
    }
    
    func removeListeners() {
        listener?.remove()
        listener = nil
    }
}
