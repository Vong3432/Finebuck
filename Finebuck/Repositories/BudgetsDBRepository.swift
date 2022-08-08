//
//  BudgetsDBRepository.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 03/05/2022.
//

import Foundation
import Combine
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
    func update(_ targetBudgeting: Budgeting, with: Budgeting) async throws -> Budgeting
    func delete(targetBudgeting: Budgeting) async throws -> Void
    func get(_ budgeting: Budgeting) async throws -> Budgeting?
    func getAll() async throws -> Void
    
    func removeListeners() -> Void
}

final class BudgetsDBRepository: BudgetsDBRepositoryProtocol, ObservableObject {
    
    @Published var budgetings = [Budgeting]()
    var budgetingsPublished: Published<[Budgeting]> { _budgetings }
    var budgetingsPublisher: Published<[Budgeting]>.Publisher { $budgetings }
    
    private let store = Firestore.firestore()
    var listener: ListenerRegistration?
    
    func save(_ budgeting: Budgeting) async throws -> Budgeting? {
        do {
            var newBudgeting = budgeting
            
            if newBudgeting.id == nil {
                let ref = try store.collection(.firestoreBudgetingsPath).addDocument(from: budgeting)
                newBudgeting = try await ref.getDocument(as: Budgeting.self)
            } else {
                try store.collection(.firestoreBudgetingsPath).document(budgeting.id!).setData(from: budgeting, merge: true)
            }
            
            return try await get(newBudgeting)
        } catch let error {
            debugPrint("Save budget err: \(error)")
            throw BudgetsDBRepositoryError.failed
        }
    }
    
    func update(_ targetBudgeting: Budgeting, with updatedBudgeting: Budgeting) async throws -> Budgeting {
        do {
            try store
                .collection(.firestoreBudgetingsPath)
                .document(targetBudgeting.id!)
                .setData(from: updatedBudgeting)
            
            return updatedBudgeting
        } catch {
            print("Unable to update card: \(error.localizedDescription).")
            throw BudgetsDBRepositoryError.failed
        }
    }
    
    func delete(targetBudgeting: Budgeting) async throws {
        do {
            try await store.collection(.firestoreBudgetingsPath).document(targetBudgeting.id!).delete()
        } catch {
            throw BudgetsDBRepositoryError.failed
        }
    }
    
    func get(_ budgeting: Budgeting) async throws -> Budgeting? {
        do {
            let budgetingRef = store.collection(.firestoreBudgetingsPath).document(budgeting.id!)
            let doc = try await budgetingRef.getDocument()
            let budgeting = try doc.data(as: Budgeting.self)
            
            return budgeting
        } catch {
            throw BudgetsDBRepositoryError.noResult
        }
    }
    
    func getAll() async throws -> Void {
        listener = store.collection(.firestoreBudgetingsPath)
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
    
    func removeListeners() {
        listener?.remove()
    }
}
