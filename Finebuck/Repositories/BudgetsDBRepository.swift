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
import Algorithms

/**
 FirebaseFirestoreSwift adds some cool functionalities to help you integrate Firestore with your models. It lets you convert Models into documents and documents into Models.
 */
import FirebaseFirestoreSwift

final class BudgetsDBRepository: FirestoreDBRepositoryProtocol, ObservableObject {
    @Published var items = [Budgeting]()
    var itemsPublished: Published<[Budgeting]> { _items }
    var itemsPublisher: Published<[Budgeting]>.Publisher { $items }
    
    @Published var fetchingMore = false
    
    internal let store = Firestore.firestore()
    internal let path = "budgetings"
    private let costPath = "costs"
    private let earningPath = "costs"
    internal var listener: ListenerRegistration?
    
    private var lastDocumentSnapshot: DocumentSnapshot!
    private var lastDeletedPlan: Budgeting?
    private let paginateCount = 10
    
    deinit {
        print("BUDGETSDBREPOSITORY DEINIT")
    }
    
    func save(_ budgeting: Budgeting) async throws -> Budgeting? {
        do {
            
            var newBudgeting = budgeting
            
            // save or update document
            if newBudgeting.id == nil {
                newBudgeting.createdAt = Timestamp.init(date: .now)
                let ref = try store.collection(path).addDocument(from: newBudgeting)
                newBudgeting = try await ref.getDocument(as: Budgeting.self)
            } else {
                try store.collection(path).document(budgeting.id!).setData(from: budgeting, merge: true)
            }
            
            let saved = try await get(newBudgeting)

            if let saved = saved, let saveId = saved.id {
                self.lastDocumentSnapshot = try await store.collection(path).document(saveId).getDocument()
                self.addItems([saved])
            }
            
            return saved
        } catch let error {
            debugPrint("Save budget err: \(error)")
            throw FirestoreDBRepositoryError.failed
        }
    }
    
    func update(_ targetBudgeting: Budgeting, with field: [String: Any]) async throws -> Void {
        do {
            try await store
                .collection(path)
                .document(targetBudgeting.id!)
                .updateData(field)
        } catch {
            print("Unable to update budget: \(error.localizedDescription).")
            throw FirestoreDBRepositoryError.failed
        }
        fatalError("Not implemented.")
    }
    
    func updateMultiple(_ items: [Budgeting], newDataArr: [[String: Any]]) async throws -> Void {
        do {
            let batch = store.batch()
            
            guard items.count == newDataArr.count else { fatalError("Items and newDataArr must have same length. ") }
            
            for (index, item) in items.enumerated() {
                let itemRef = store.collection(path).document(item.id!)
                batch.updateData(newDataArr[index], forDocument: itemRef)
            }
            
            try await batch.commit()
        } catch {
            throw FirestoreDBRepositoryError.failed
        }
    }
    
    func delete(item targetBudgeting: Budgeting) async throws {
        do {
            guard let id = targetBudgeting.id else {
                throw FirestoreDBRepositoryError.noResult
            }
            self.lastDeletedPlan = targetBudgeting
            try await store.collection(path).document(id).delete()
            print("DELETE plan ok")
        } catch {
            throw FirestoreDBRepositoryError.failed
        }
    }
    
    func get(_ budgeting: Budgeting) async throws -> Budgeting? {
        do {
            let budgetingRef = store.collection(path).document(budgeting.id!)
            let doc = try await budgetingRef.getDocument()
            let budgeting = try doc.data(as: Budgeting.self)
            
            return budgeting
        } catch {
            throw FirestoreDBRepositoryError.noResult
        }
    }
    
    func getAll(fromUserId: String) async throws -> Void {
        do {
            var query: Query!
            
            /// Refer to https://stackoverflow.com/a/52216994/10868150 for pagination in firestore.
            /// Only fetch first `paginateCount` of items.
            if items.isEmpty {
                query = store.collection(path)
                    .whereField("creatorUid", isEqualTo: fromUserId)
                    .order(by: "createdAt", descending: true)
                    .limit(to: paginateCount)
            } else {
                query = store.collection(path)
                    .whereField("creatorUid", isEqualTo: fromUserId)
                    .order(by: "createdAt", descending: true)
                    .start(atDocument: lastDocumentSnapshot)
                    .limit(to: paginateCount)
            }
            
            
            // Attach listener
            listener = query
                .addSnapshotListener { [weak self] in
                    self?.handleSnapshotChanges(snapshot: $0, error: $1)
                }
            
            // Start fetching
            let snapshot = try await query.getDocuments()
            
            // Done fetching
            let items = try snapshot.documents.map { doc in
                try doc.data(as: Budgeting.self)
            }
            
            self.addItems(items)
            self.lastDocumentSnapshot = snapshot.documents.last
            
            if fetchingMore {
                fetchingMore = false
            }
            
            // Update outdated models (if needed)
            let outdatedBudgetPlanStructures = items.filter { $0.createdAt == nil }
            if outdatedBudgetPlanStructures.isEmpty == false {
                var dict: [String: Any] = [:]
                dict["createdAt"] = FieldValue.serverTimestamp()
                
                try? await self.updateMultiple(
                    outdatedBudgetPlanStructures,
                    newDataArr: Array.init(repeating: dict, count: outdatedBudgetPlanStructures.count)
                )
            }
        } catch {
            fetchingMore = false
            throw FirestoreDBRepositoryError.failed
        }
    }
    
    func loadMore(fromUserId: String) async throws {
        //        removeListeners()
        //
        //        let query = store.collection(path)
        //            .whereField("creatorUid", isEqualTo: fromUserId)
        //            .start(atDocument: lastDocumentSnapshot)
        //
        //        listener = query.addSnapshotListener { [weak self] in
        //            self?.handleSnapshotChanges(snapshot: $0, error: $1)
        //        }
        //
        //        // fetching
        //        self.fetchingMore = true
        //        let snapshot = try await query.getDocuments()
        //
        //        // convert
        //        let items = try snapshot.documents.map { doc in
        //            try doc.data(as: Budgeting.self)
        //        }
        //
        //        self.fetchingMore = false
        //
        //        if items.isEmpty == false {
        //            print("LOAD MORE OK")
        //            self.addItems(items)
        //            self.lastDocumentSnapshot = snapshot.documents.last
        //        }
    }
    
    func reset() {
        items = []
        lastDocumentSnapshot = nil
    }
    
    func removeListeners() {
        listener?.remove()
        listener = nil
    }
}

extension BudgetsDBRepository {
    /// Make sure the items data are always unique
    private func addItems(_ newItems: [Budgeting]) {
        let newItems = (items + newItems).uniqued { $0.id }
        self.items = newItems
    }
    
    private func handleSnapshotChanges(snapshot: QuerySnapshot?, error: Error?) -> Void {
        guard let snapshot = snapshot else {
            print("Error fetching snapshots: \(error!)")
            return
        }
        
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        // Handle snapshot event changes
        snapshot.documentChanges.forEach { [weak self] doc in
            guard let bud = try? doc.document.data(as: Budgeting.self) else {
                fatalError()
            }
            
            if doc.type == .added {
                self?.addItems([bud])
                self?.lastDocumentSnapshot = doc.document
            }
            
            if doc.type == .modified {
                guard let idx = self?.items.firstIndex(where: { b in
                    b.id == bud.id
                }) else { return }
                self?.items[idx] = bud
            }
            
            
            /// If `.removed`, things getting more interesting.
            /// Because it will be called when not only because users perform deletion but also query changes =)
            if doc.type == .removed {
                guard let self = self,
                      let idx = self.items.firstIndex(where: { $0.id == bud.id }) else { return }
                
                // Check whether this is deletion or triggered because query is changed
                // Separated this guard from above for better readability..
                guard bud.id == self.lastDeletedPlan?.id else {
                    // Called because query is changed...
                    return
                }
                
                // Called because of deletion...
                // update cursor!
                store.collection(path)
                    .end(beforeDocument: doc.document)
                    .getDocuments { [weak self] snapshot, _ in
                        self?.lastDocumentSnapshot = snapshot?.documents.last
                }
                
                // remove items
                self.items.remove(at: idx)
                
            }
        }
    }
}
