
//  HomeView.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 23/04/2022.
//

import SwiftUI
import Resolver
import UniformTypeIdentifiers
import FirebaseAuth

struct HomeView: View {
    
    @ObservedObject var authService: AnyFirebaseAuthService<User>
    @StateObject private var vm: HomeViewModel
    
    // UI
    @State private var showingAlert = false
    @State private var selectedBudgetingPlan: Budgeting?
    
    private var username: String {
        authService.profile?.username ?? "-"
    }
    
    init(authService: AnyFirebaseAuthService<User>) {
        self.authService = authService
        _vm = StateObject(wrappedValue: HomeViewModel(authService: authService))
    }
    
    var body: some View {
        ZStack {
            Color.theme.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    greeting
//                    templates
                    saved
                }.buttonStyle(.plain)
            }
            .padding()
            .padding(.bottom)
        }
        .alert("Confirm to delete?", isPresented: $showingAlert, presenting: selectedBudgetingPlan) { budgetPlan in
            Button("Yes", role: .destructive) { vm.deleteBudgetPlan(for: budgetPlan) }
            Button("Cancel", role: .cancel) { }
        }
        .navigationTitle("finebuck")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Resolver.Name.mode = .mock
        
        return NavigationView {
            HomeView(authService: AnyFirebaseAuthService<User>(FirebaseAuthService()))
        }
        .environmentObject(AppState())
        .preferredColorScheme(.dark)
    }
}

extension HomeView {
    // MARK: - Actions
    private func showAlertConfirmation() {
        showingAlert = true
    }
    
    // MARK: - Views
    private var greeting: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Hi \(username)")
                .font(FBFonts.kanitMedium(size: .fontSize(.largeTitle)))
            
            Text("You have use finebuck to help you do budgeting for **6** times!")
                .font(FBFonts.kanitRegular(size: .body))
                .foregroundColor(Color.theme.text.opacity(0.6))
            
            Spacer()
            
            NavigationLink {
                BudgetingDetailView(budgeting: nil, authService: authService)
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
    
    // Desc order
    private var sortedBudgetingPlans: [Budgeting] {
        vm.budgetings.sorted().reversed()
    }
    
    private var saved: some View {
        LazyVStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Saved plans")
                    .font(FBFonts.kanitBold(size: .headline))
                Spacer()
            }
            ForEach(sortedBudgetingPlans) { budgeting in
                NavigationLink {
                    BudgetingDetailView(budgeting: budgeting, authService: authService)
                } label: {
                    BudgetPlanItemView(budgeting: budgeting)
                        .contextMenu {
                            Button("Delete") {
                                selectedBudgetingPlan = budgeting
                                showAlertConfirmation()
                            }
                        }
                        .onAppear {
                            if budgeting == vm.budgetings.last {
                                vm.loadMore()
                            }
                        }
                }
            }
            
            if vm.isFetchingMore {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
}
