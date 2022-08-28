//
//  AppDelegate+Injection.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 05/05/2022.
//

import Foundation
import Resolver

extension Resolver.Name {
    static let app = Self("app")
    static let mock = Self("mock")
    static let mockFailed = Self("mockFailed")
    static var mode: Resolver.Name = .app
}

extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        
        register {
            resolve(name: .mode) as AnyFirestoreDBRepository<Budgeting>
        }
        
        // for another protocol
//        register {
//            resolve(name: .mode) as XYZProtocol
//        }
        
        register(name: .app) {
            AnyFirestoreDBRepository(BudgetsDBRepository()) as AnyFirestoreDBRepository<Budgeting>
        }.scope(.application)
        
        register(name: .mock) {
            AnyFirestoreDBRepository(MockBudgetsDBRepository()) as AnyFirestoreDBRepository<Budgeting>
        }
        
        register(name: .mockFailed) {
            AnyFirestoreDBRepository(MockedBudgetsDBRepositoryFailed()) as AnyFirestoreDBRepository<Budgeting>
        }
    }
}

//
extension Resolver {
//    // MARK: - Mock Container
//    static var mock = Resolver()
//    
//    // MARK: - Register Mock Services
//    static func registerMockServices() {
//        root = Resolver.mock
//        defaultScope = .application
//        
//        Resolver.mock.register { MockBudgetsDBRepository() }.implements(BudgetsDBRepositoryProtocol.self)
//    }
//    
//    // MARK: - Register Failed Mock Services
//    static func registerFailMockServices() {
//        root = Resolver.mock
//        defaultScope = .application
//        
//        Resolver.mock.register { MockedBudgetsDBRepositoryFailed() }.implements(BudgetsDBRepositoryProtocol.self)
//    }
}
