//
//  AuthorizedRootView.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 07/08/2022.
//

import SwiftUI

extension AuthorizedRootView {
    enum Tab: Hashable {
        case home
        case templates
        case modules
        case profile
    }
}

struct AuthorizedRootView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            
            // Home
            NavigationView {
                HomeView(authService: appState.authService)
            }
            .navigationViewStyle(.stack)
            .tabItem {
                loadSVG("Home")
                Text("Home")
            }
            .tag(Tab.home)
            
            // Templates
            NavigationView {
                TemplatesView()
            }
            .navigationViewStyle(.stack)
            .tabItem {
                loadSVG("Templates")
                Text("Templates")
            }
            .tag(Tab.templates)
            
            // Modules
            NavigationView {
                ModulesView()
            }
            .navigationViewStyle(.stack)
            .tabItem {
                loadSVG("Modules")
                Text("Modules")
            }
            .tag(Tab.modules)
            
            // Profile
            NavigationView {
                ProfileView()
                    .navigationTitle("Profile")
            }
            .navigationViewStyle(.stack)
            .tabItem {
                loadSVG("Profile")
                Text("Profile")
            }
            .tag(Tab.profile)
        }
        .preferredColorScheme(.dark)
        .foregroundColor(Color.theme.text)
        .customTint(Color.theme.primary)
    }
    
}

struct AuthorizedRootView_Previews: PreviewProvider {
    static var previews: some View {
        AuthorizedRootView()
            .environmentObject(AppState())
    }
}
