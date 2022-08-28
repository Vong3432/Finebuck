//
//  AppState.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 23/04/2022.
//

import Foundation
import Combine

final class AppState: ObservableObject {
    @Published var selectedTab: AuthorizedRootView.Tab = .home
    @Published var showActionSheet: Bool = false
    
    private(set) var authService = AnyFirebaseAuthService( FirebaseAuthService())
    private var cancellable = Set<AnyCancellable>()
    
    init() {
        
        authService.userPublisher.sink { [weak self] _ in
            // switch to home tab if user logged out
            if self?.authService.isAuthenticated == false {
                self?.selectedTab = .home
            }
        }.store(in: &cancellable)
    }
}

