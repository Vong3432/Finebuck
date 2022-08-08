//
//  SignInView.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 07/08/2022.
//

import SwiftUI
import AuthenticationServices
import FirebaseAuth
import GoogleSignInSwift

struct SignInView: View {
    
    @StateObject private var vm: SignInViewModel
    var authService: FirebaseAuthServiceProtocol
    
    init(authService: FirebaseAuthServiceProtocol) {
        _vm = StateObject(wrappedValue: SignInViewModel(authService: authService))
        self.authService = authService
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.background.ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    previews
                    signInBtns
                }
                .padding(.vertical)
                .padding()
                
            }
            .navigationTitle("About Finebuck")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
        .preferredColorScheme(.dark)
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(authService: FirebaseAuthService())
    }
}

extension SignInView {
    
    private var previews: some View {
        TabView {
            VStack(alignment: .leading, spacing: 20) {
                Image("p1")
                    .resizable()
                    .padding()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                
                Text("Customizable label")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.top)
                Text("Labels every item of your budget plan as you want.")
                    .lineLimit(3)
                    .lineSpacing(8)
                    .opacity(0.75)
                Spacer()
            }
            .padding(.top)
            
            VStack(alignment: .leading, spacing: 20) {
                Image("p2")
                    .resizable()
                    .padding()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    .shadow(radius: 20)
                
                Text("Reusable templates")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.top)
                Text("Create your own templates for commonly used budget expenses and earnings.")
                    .lineLimit(3)
                    .lineSpacing(8)
                    .opacity(0.75)
                
                Spacer()
            }
            .padding(.top)
        }
        .frame(height: 550)
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
    
    private var signInBtns: some View {
        VStack {
            SignInWithAppleButton { request in
                vm.startAppleSignInProcess(request: request)
            } onCompletion: { result in
                vm.verifyAppleSignIn(result: result)
            }.frame(height: 48)
            
            GoogleSignInBtnView(style: .wide, authService: authService)
                .frame(height: 48)
        }
    }
}