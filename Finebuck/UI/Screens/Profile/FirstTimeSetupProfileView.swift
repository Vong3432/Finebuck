//
//  FirstTimeSetupProfileView.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 08/08/2022.
//

import SwiftUI

struct FirstTimeSetupProfileView: View {
    @State private var username: String = ""
    @EnvironmentObject var appState: AppState
    
    private var showBtn: Bool {
        username.trimmingCharacters(in: .whitespaces).isEmpty == false
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Color.theme.background.ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    Section {
                        TextField("Username", text: $username)
                            .itemOutlinedStyle()
                    } header: {
                        Text("Username".uppercased())
                            .font(FBFonts.kanitMedium(size: .subheadline))
                            .opacity(0.6)
                    }
                    
                    Spacer()
                    
                    if showBtn {
                        Button {
                            createProfile()
                        } label: {
                            Text("Done")
                                .font(FBFonts.kanitRegular(size: .body))
                                .frame(maxWidth: .infinity)
                                .itemFilledStyle()
                        }
                        .buttonStyle(.plain)
                    }

                }.padding()
            }
            .navigationTitle("One more step..")
        }
        .preferredColorScheme(.dark)
        .navigationViewStyle(.stack)
    }
    
    private func createProfile() {
        appState.authService.saveProfile(name: username)
    }
}

struct FirstTimeSetupProfileView_Previews: PreviewProvider {
    static var previews: some View {
        FirstTimeSetupProfileView()
    }
}
