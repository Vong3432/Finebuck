//
//  BudgetingDetailView.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 24/04/2022.
//

import SwiftUI
import HalfModal
import Resolver


struct BudgetingDetailView: View {
    private enum Field: Int, CaseIterable {
        case title
    }
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @StateObject var vm: BudgetingDetailViewModel
    @FocusState private var focusedField: Field?
    
    init(budgeting: Budgeting?, dataService: BudgetsDBRepository = BudgetsDBRepository()) {
        _vm = StateObject(wrappedValue: BudgetingDetailViewModel(budgeting: budgeting))
    }
    
    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()
            
            VStack {
                
                ScrollView(.vertical) {
                    heading
                    content
                }
                .padding()
                
                addItemBtn
            }
            
        }
        .onChange(of: focusedField, perform: { newValue in
            if newValue == nil {
                vm.endEditingTitle()
            }
        })
        .sheet(isPresented: $appState.showActionSheet) {
            BudgetPlanDetailFormView(
                calculationItem: vm.selectedCalculationItem,
                onDone: closeSheet)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                CloseBarItem(dismiss: .constant(dismiss), text: "Save")
            }
        }
//        .sheet(isPresented: $appState.showActionSheet, detents: [.medium(), .large()], selectedDetentIdentifier: .medium, cornerRadius: 15.0) {
//
//        }
    }
    
    private func closeSheet(_ savedBudgetItem: BudgetItem) {
        Task {
            await vm.saveBudgeting(budgetItem: savedBudgetItem)
            vm.viewBudgetItem(nil)
        }
        appState.showActionSheet = false
    }
    
    private func generateBudgetItemSubtitle(_ budget: BudgetItem) -> String {
        
        if budget.type == .fixed {
            return budget.type.rawValue
        } else {
            return "\(budget.type.rawValue) \(budget.rate?.asPercentString() ?? "0%")"
        }
    }
}

struct BudgetingDetailView_Previews: PreviewProvider {
    
    static var previews: some View {
        Resolver.registerMockServices()
        
        return Group {
            NavigationView {
                BudgetingDetailView(budgeting: nil)
            }
            .previewDisplayName("Create budgeting")
            
            //            NavigationView {
            //                BudgetingDetailView(budgeting: .mockBudgetingItems[0])
            //            }
            //            .preferredColorScheme(.dark)
            //            .previewDisplayName("Edit budgeting")
        }
        .preferredColorScheme(.dark)
        .environmentObject(AppState())
    }
}

extension BudgetingDetailView {
    private var heading: some View {
        HStack {
            TextField("", text: $vm.title)
                .focused($focusedField, equals: .title)
                .disabled(!vm.isEditingTitle)
                .font(FBFonts.kanitMedium(size: .largeTitle))
            
            Spacer()
            Button {
                vm.startEditingTitle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {  /// Anything over 0.1 seems to work
                    focusedField = .title
                }
            } label: {
                loadSVG("Edit")
                    .padding(.leading)
                    .opacity(vm.isEditingTitle ? 0.3 : 1.0)
                    .animation(.linear, value: vm.isEditingTitle)
            }
        }
    }
    
    private var content: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 30) {
                costs
                earning
                net
            }
            .disabled(vm.isEditingTitle)
            .opacity(vm.isEditingTitle ? 0.3 : 1.0)
            .offset(x: 0, y: vm.isEditingTitle ? 10.0: 0.0)
            .animation(
                .spring().delay(0.3),
                value: vm.isEditingTitle
            )
        }
        .padding(.top)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var costs: some View {
        VStack(alignment: .leading, spacing: 10) {
            Section {
                if let costs = vm.budgeting?.costs {
                    ForEach(costs) { cost in
                        Button {
                            appState.showActionSheet = true
                            vm.viewBudgetItem(cost)
                        } label: {
                            OutlinedItemView(
                                title: cost.title,
                                subtitle: generateBudgetItemSubtitle(cost),
                                trailing: cost.formattedValue)
                        }
                    }
                } else {
                    Text("No data found ...")
                        .font(FBFonts.kanitRegular(size: .body))
                        .opacity(0.6)
                }
            } header: {
                Text("Costs".uppercased())
                    .font(FBFonts.kanitMedium(size: .subheadline))
                    .opacity(0.6)
            }
        }
    }
    
    private var earning: some View {
        VStack(alignment: .leading, spacing: 10) {
            Section {
                if let earnings = vm.budgeting?.earning {
                    ForEach(earnings) { earning in
                        Button {
                            appState.showActionSheet = true
                            vm.viewBudgetItem(earning)
                        } label: {
                            OutlinedItemView(
                                title: earning.title,
                                subtitle: generateBudgetItemSubtitle(earning),
                                trailing: earning.formattedValue)
                        }
                    }
                } else {
                    Text("No data found ...")
                        .font(FBFonts.kanitRegular(size: .body))
                        .opacity(0.6)
                }
            } header: {
                Text("Earnings".uppercased())
                    .font(FBFonts.kanitMedium(size: .subheadline))
                    .opacity(0.6)
            }
        }
    }
    
    private var net: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let budgeting = vm.budgeting {
                Section {
                    OutlinedItemView(
                        title: "Total",
                        trailing: budgeting.formattedNet)
                } header: {
                    Text("Net".uppercased())
                        .font(FBFonts.kanitMedium(size: .subheadline))
                        .opacity(0.6)
                }
            }
        }
    }
    
    private var addItemBtn: some View {
        VStack {
            Button {
                vm.viewBudgetItem(nil)
                appState.showActionSheet = true
            } label: {
                loadSVG("Plus")
                Text("Add cost or earning")
                    .font(FBFonts.kanitRegular(size: .body))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .itemFilledStyle()
            .buttonStyle(.plain)
            .padding()
        }
        .opacity(vm.isEditingTitle ? 0 : 1)
        .animation(
            .spring().delay(vm.isEditingTitle ? 0 : 0.5),
            value: vm.isEditingTitle)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
