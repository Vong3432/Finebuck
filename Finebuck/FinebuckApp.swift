//
//  FinebuckApp.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 23/04/2022.
//

import SwiftUI

@main
struct FinebuckApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView(authService: appState.authService)
                .environmentObject(appState)
        }
    }
}
