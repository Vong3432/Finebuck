//
//  ProfileView.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 23/04/2022.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var appState: AppState
    
    init() {
        UITableView.appearance().backgroundColor = UIColor(Color.theme.background)
    }
    
    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()
            
            List {
                Button {
                    appState.authService.logout()
                } label: {
                    Text("Sign out")
                }
            }.background(Color.theme.background)

        }
        .preferredColorScheme(.dark)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
        ProfileView()
        }
    }
}
