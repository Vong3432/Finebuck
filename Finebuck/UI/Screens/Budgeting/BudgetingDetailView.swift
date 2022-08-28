//
//  BudgetingDetailView.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 24/04/2022.
//

import SwiftUI
import Resolver
import UniformTypeIdentifiers
import FirebaseAuth

struct BudgetingDetailView: View {
    private enum Field: Int, CaseIterable {
        case title
    }
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @StateObject var vm: BudgetingDetailViewModel
    
    // UI
    @FocusState private var focusedField: Field?
    @State private var draggedCost: Budgeting.Cost?
    @State private var draggedEarning: Budgeting.Earning?
    @State private var showAlert = false
    @State private var selectedBudgetItem: BudgetItem?
    
    init(budgeting: Budgeting?, authService: AnyFirebaseAuthService<User>) {
        _vm = StateObject(
            wrappedValue: BudgetingDetailViewModel(
                budgeting: budgeting,
                authService: authService
            )
        )
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
                Button {
                    vm.saveToCloud()
                } label: {
                    if vm.isLoading {
                        ProgressView()
                    } else {
                        Text("Save")
                    }
                }.foregroundColor(Color.theme.primary)
            }
        }
        .alert("Delete this item?", isPresented: $showAlert, presenting: selectedBudgetItem) { item in
            Button("Yes", role: .destructive) {
                vm.deleteBudgetItem(of: item)
            }
            Button("Cancel", role: .cancel) { }
        }
    }
    
}

struct BudgetingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        Resolver.Name.mode = .mock
        
        return Group {
            NavigationView {
                BudgetingDetailView(budgeting: .mockBudgetingItems[0], authService: AnyFirebaseAuthService(FirebaseAuthService()))
                    .navigationBarTitleDisplayMode(.inline)
            }
            .previewDisplayName("Create budgeting")
        }
        .preferredColorScheme(.dark)
        .environmentObject(AppState())
    }
}

extension BudgetingDetailView {
    // MARK: - Actions
    private func closeSheet(_ savedBudgetItem: BudgetItem) {
        Task {
            vm.saveBudgeting(budgetItem: savedBudgetItem)
            vm.viewBudgetItem(nil)
        }
        appState.showActionSheet = false
    }
    
    private func generateBudgetItemSubtitle(_ budget: BudgetItem) -> String {
        if budget.type == .fixed {
            return budget.type.rawValue
        } else {
            return "\(budget.type.rawValue) \(budget.rate?.asPercentString() ?? "0%") of \(budget.value)"
        }
    }
    
    private func showDeleteConfirmation() {
        showAlert = true
    }

    // MARK: - Views
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
        
        .padding(.top)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var costs: some View {
        VStack(alignment: .leading, spacing: 10) {
            Section {
                if vm.costs.isEmpty == false {
                    ForEach(vm.costs) { cost in
                        Button { [unowned vm] in
                            appState.showActionSheet = true
                            vm.viewBudgetItem(cost)
                        } label: {
                            OutlinedItemView(
                                title: cost.title,
                                subtitle: generateBudgetItemSubtitle(cost),
                                trailing: cost.formattedValue)
                            .contextMenu {
                                Button("Delete") {
                                    selectedBudgetItem = cost
                                    showDeleteConfirmation()
                                }
                            }
                            .onDrag {
                                self.draggedCost = cost
                                return NSItemProvider(item: nil, typeIdentifier: cost.id)
                            }
                            .onDrop(
                                of: [UTType.text],
                                delegate: MyDropDelegate<Budgeting.Cost>(
                                    item: cost,
                                    items: $vm.costs,
                                    draggedItem: $draggedCost,
                                    completion: { first, second in
                                        let firstCost = vm.costs[first]
                                        let secondCost = vm.costs[second]
                                        
                                        vm.costs[first].index = secondCost.index ?? 0
                                        vm.costs[second].index = firstCost.index ?? 0
                                    }
                                )
                            )
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
                if vm.earnings.isEmpty == false {
                    ForEach(vm.earnings) { earning in
                        Button { [unowned vm] in
                            appState.showActionSheet = true
                            vm.viewBudgetItem(earning)
                        } label: {
                            OutlinedItemView(
                                title: earning.title,
                                subtitle: generateBudgetItemSubtitle(earning),
                                trailing: earning.formattedValue)
                            .contextMenu {
                                Button("Delete") {
                                    selectedBudgetItem = earning
                                    showDeleteConfirmation()
                                }
                            }
                            .onDrag {
                                self.draggedEarning = earning
                                return NSItemProvider(item: nil, typeIdentifier: earning.id)
                            }
                            .onDrop(
                                of: [UTType.text],
                                delegate: MyDropDelegate<Budgeting.Earning>(
                                    item: earning,
                                    items: $vm.earnings,
                                    draggedItem: $draggedEarning,
                                    completion: { first, second in
                                        let firstEarning = vm.earnings[first]
                                        let secondEarning = vm.earnings[second]
                                        
                                        vm.earnings[first].index = secondEarning.index ?? 0
                                        vm.earnings[second].index = firstEarning.index ?? 0
                                    }
                                )
                            )
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
                HStack {
                    loadSVG("Plus")
                    Text("Add cost or earning")
                        .font(FBFonts.kanitRegular(size: .body))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .itemFilledStyle()
            }
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
