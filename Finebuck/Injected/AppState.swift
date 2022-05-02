//
//  AppState.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 23/04/2022.
//

import Foundation

protocol AppStateProtocol {
    var selectedTab: ContentView.Tab { get set }
    var showActionSheet: Bool { get set }
}

final class AppState: ObservableObject, AppStateProtocol {
    @Published var selectedTab: ContentView.Tab = .home
    @Published var showActionSheet: Bool = false
}

