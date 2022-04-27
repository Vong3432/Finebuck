//
//  ContentView.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 23/04/2022.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            
            // Home
            NavigationView {
                HomeView()
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
        .customTint(Color.theme.text)
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
    }
}

extension ContentView {
    enum Tab: Hashable {
        case home
        case templates
        case modules
        case profile
    }
}
