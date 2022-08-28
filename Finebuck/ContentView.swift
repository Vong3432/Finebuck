//
//  ContentView.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 23/04/2022.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @ObservedObject var authService: AnyFirebaseAuthService<User>
    
    var body: some View {
        if authService.isLoading {
            ZStack {
                Color.theme.background.ignoresSafeArea()
                ProgressView()
            }.preferredColorScheme(.dark)
        } else {
            if authService.isAuthenticated {
                if authService.profile == nil {
                    FirstTimeSetupProfileView()
                } else {
                    AuthorizedRootView()
                }
                
            } else {
                SignInView(authService: authService)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(authService: AnyFirebaseAuthService( FirebaseAuthService()))
    }
}
