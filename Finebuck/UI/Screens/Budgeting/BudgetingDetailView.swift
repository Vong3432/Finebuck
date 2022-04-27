//
//  BudgetingDetailView.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 24/04/2022.
//

import SwiftUI
import HalfModal


struct BudgetingDetailView: View {
    private enum Field: Int, CaseIterable {
        case title
    }
    
    let budgeting: Budgeting?
    
    @EnvironmentObject var appState: AppState
    
    @State private var selectedCalculationItem: BudgetItem? = nil
    @State private var title: String = ""
    @State private var isEditingTitle = false
    @FocusState private var focusedField: Field?
    
    init(budgeting: Budgeting? = nil) {
        self.budgeting = budgeting
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
        .onAppear {
            title = budgeting?.title ?? "Budgeting"
        }
        .sheet(isPresented: $appState.showActionSheet, detents: [.medium(), .large()], selectedDetentIdentifier: .medium, cornerRadius: 15.0) {
            BudgetPlanDetailFormView(calculationItem: selectedCalculationItem)
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    isEditingTitle = false
                    focusedField = nil
                }
            }
        }
    }
}

struct BudgetingDetailView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            NavigationView {
                BudgetingDetailView()
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
            TextField("", text: $title)
                .focused($focusedField, equals: .title)
                .disabled(!isEditingTitle)
                .font(FBFonts.kanitMedium(size: .largeTitle))
            
            Spacer()
            Button {
                isEditingTitle = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {  /// Anything over 0.1 seems to work
                    focusedField = .title
                }
            } label: {
                loadSVG("Edit")
                    .padding(.leading)
                    .opacity(isEditingTitle ? 0.3 : 1.0)
                    .animation(.linear, value: isEditingTitle)
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
            .disabled(isEditingTitle)
            .opacity(isEditingTitle ? 0.3 : 1.0)
            .offset(x: 0, y: isEditingTitle ? 10.0: 0.0)
            .animation(
                .spring().delay(0.3),
                value: isEditingTitle
            )
        }
        .padding(.top)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var costs: some View {
        VStack(alignment: .leading, spacing: 10) {
            Section {
                if let costs = budgeting?.costs {
                    ForEach(costs) { cost in
                        Button {
                            appState.showActionSheet = true
                            selectedCalculationItem = cost
                        } label: {
                            OutlinedItemView(
                                title: cost.title,
                                subtitle: cost.type.rawValue,
                                trailing: cost.formattedCost)
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
                if let earnings = budgeting?.earning {
                    ForEach(earnings) { earning in
                        Button {
                            appState.showActionSheet = true
                            selectedCalculationItem = earning
                        } label: {
                            OutlinedItemView(
                                title: earning.title,
                                subtitle: earning.type.rawValue,
                                trailing: earning.formattedCost)
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
            if let budgeting = budgeting {
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
                selectedCalculationItem = nil
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
        .opacity(isEditingTitle ? 0 : 1)
        .animation(
            .spring().delay(isEditingTitle ? 0 : 0.5),
            value: isEditingTitle)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
