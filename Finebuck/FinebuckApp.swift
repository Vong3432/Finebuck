//
//  FinebuckApp.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 23/04/2022.
//

import SwiftUI

@main
struct FinebuckApp: App {
    @StateObject var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}
