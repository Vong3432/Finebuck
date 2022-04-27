//
//  AppState.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 23/04/2022.
//

import Foundation

final class AppState: ObservableObject {
    @Published var selectedTab: ContentView.Tab = .home
    @Published var showActionSheet: Bool = false
}
