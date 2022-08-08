
//  HomeView.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 23/04/2022.
//

import SwiftUI
import Resolver

struct HomeView: View {
    
    @EnvironmentObject private var appState: AppState
    @StateObject private var vm: HomeViewModel
    
    private var username: String {
        appState.authService.profile?.username ?? "-"
    }
    
    init() {
        _vm = StateObject(wrappedValue: HomeViewModel())
    }
    
    var body: some View {
        ZStack {
            Color.theme.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    greeting
                    templates
                    saved
                }.buttonStyle(.plain)
            }
            .padding()
            .padding(.bottom)
        }
        .navigationTitle("finebuck")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Resolver.Name.mode = .mock
        
        return NavigationView {
            HomeView()
        }
        .environmentObject(AppState())
        .preferredColorScheme(.dark)
    }
}

extension HomeView {
    private var greeting: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Hi \(username)")
                .font(FBFonts.kanitMedium(size: .fontSize(.largeTitle)))
            
            Text("You have use finebuck to help you do budgeting for **6** times!")
                .font(FBFonts.kanitRegular(size: .body))
                .foregroundColor(Color.theme.text.opacity(0.6))
            
            Spacer()
            
            NavigationLink {
                BudgetingDetailView(budgeting: nil, authService: appState.authService)
            } label: {
                createNewBudgetBtn
            }
            
        }
    }
    
    private var createNewBudgetBtn: some View {
        HStack(spacing: 12) {
            loadSVG("Plus")
            Text("Start with no template")
                .font(FBFonts.kanitRegular(size: .fontSize(.body)))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .itemFilledStyle()
    }
    
    private var templates: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Templates")
                .font(FBFonts.kanitBold(size: .headline))
            
            Text("Use your own or existing templates to start budgeting!")
                .font(FBFonts.kanitRegular(size: .subheadline))
                .foregroundColor(Color.theme.text.opacity(0.6))
            
            Spacer()
            
            ScrollView(.horizontal) {
                HStack(spacing: 20) {
                    ForEach(Template.mockedTemplates) { template in
                        TemplateCardView(template: template)
                            .frame(width: 150)
                    }
                }
            }
        }
    }
    
    private var saved: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Saved plans")
                .font(FBFonts.kanitBold(size: .headline))
            ForEach(vm.budgetings) { budgeting in
                NavigationLink {
                    BudgetingDetailView(budgeting: budgeting, authService: appState.authService)
                } label: {
                    BudgetPlanItemView(budgeting: budgeting)
                        .contextMenu {
                            Button("Delete") { }
                        }
                }
            }
        }
    }
}
