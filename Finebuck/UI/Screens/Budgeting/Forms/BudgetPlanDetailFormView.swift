//
//  BudgetPlanDetailFormView.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 26/04/2022.
//

import SwiftUI

struct BudgetPlanDetailFormView: View {
    
    private enum Field: Int, CaseIterable {
        case amount, label, rate
    }
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: BudgetPlanDetailFormViewModel
    @FocusState private var focusedField: Field?
    
    init(calculationItem: BudgetItem? = nil) {
        self._vm = StateObject(wrappedValue: BudgetPlanDetailFormViewModel(budgetItem: calculationItem))
    }
    
    var body: some View {
        ScrollView(.vertical) {
            content
            doneBtn
        }
        .foregroundColor(Color.theme.text)
        .background(Color.theme.background)
    }
    
    
    private var formTitle: String {
        vm.calculationItem == nil ? "Add" : "Edit"
    }
}

struct BudgetPlanDetailFormView_Previews: PreviewProvider {
    static private let mocked =  Budgeting.mockBudgetingItems[0].costs[0]
    
    static var previews: some View {
        ZStack {
            BudgetPlanDetailFormView(calculationItem: mocked)
        }
        .preferredColorScheme(.dark)
    }
}

extension BudgetPlanDetailFormView {
    private var content: some View {
        VStack(alignment: .leading, spacing: 30) {
            Text(formTitle)
                .font(FBFonts.kanitMedium(size: .title))
            
            VStack(alignment: .leading, spacing: 25) {
                budgetPlanDetailFormType
                budgetPlanDetailFormCalculateType
                rateField
                fixedAmountField
                labelTextField
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .onChange(of: vm.budgetCalculateType) { vm.switchCalculateType(to: $0) }
    }
    
    private var budgetPlanDetailFormType: some View {
        Section {
            HStack {
                Button {
                    vm.switchFormType(isCost: true)
                } label: {
                    Text("Cost")
                        .padding()
                        .font(FBFonts.kanitSemiBold(size: .headline))
                }
                .frame(maxWidth: .infinity)
                .itemOutlinedStyle(borderColor: vm.isCost ? Color.theme.primary : Color.theme.gray)
                
                
                Spacer()
                
                Button {
                    vm.switchFormType(isCost: false)
                } label: {
                    Text("Earning")
                        .padding()
                        .font(FBFonts.kanitSemiBold(size: .headline))
                }
                .frame(maxWidth: .infinity)
                .itemOutlinedStyle(borderColor: !vm.isCost ? Color.theme.primary : Color.theme.gray)
            }
        } header: {
            Text("This is".uppercased())
                .font(FBFonts.kanitMedium(size: .subheadline))
                .opacity(0.6)
        }
    }
    
    private var budgetPlanDetailFormCalculateType: some View {
        Section {
            HStack {
                Button {
                    vm.switchCalculateType(to: .fixed)
                } label: {
                    Text(Budgeting.CalculateType.fixed.rawValue)
                        .padding()
                        .font(FBFonts.kanitSemiBold(size: .headline))
                }
                .frame(maxWidth: .infinity)
                .itemOutlinedStyle(borderColor: vm.budgetCalculateType == .fixed ? Color.theme.primary : Color.theme.gray)
                
                
                Spacer()
                
                Button {
                    vm.switchCalculateType(to: .rate)
                } label: {
                    Text(Budgeting.CalculateType.rate.rawValue)
                        .padding()
                        .font(FBFonts.kanitSemiBold(size: .headline))
                }
                .frame(maxWidth: .infinity)
                .itemOutlinedStyle(borderColor: vm.budgetCalculateType == .rate ? Color.theme.primary : Color.theme.gray)
            }
        } header: {
            Text("Type".uppercased())
                .font(FBFonts.kanitMedium(size: .subheadline))
                .opacity(0.6)
        }
    }
    
    private var fixedAmountField: some View {
        Section {
            TextField("", value: $vm.amount, format: .number)
                .focused($focusedField, equals: .amount)
                .placeholder(when: vm.amount == nil) {
                    Text("Enter amount")
                        .opacity(0.6)
                }
                .font(FBFonts.kanitRegular(size: .body))
                .itemOutlinedStyle()
            
            
            //            TextField("", value: $amount, format: .number)
            //                .keyboardType(.decimalPad)
            //                .focused($focusedField, equals: .amount)
            //                .placeholder(when: amount == nil) {
            //                    Text("Enter amount")
            //                        .opacity(0.6)
            //                }
            //                .font(FBFonts.kanitRegular(size: .body))
            //                .itemOutlinedStyle()
        } header: {
            Text("Amount".uppercased())
                .font(FBFonts.kanitMedium(size: .subheadline))
                .opacity(0.6)
        }
        .isHidden(vm.fixedAmountFieldOpacity == 0, remove: vm.fixedAmountFieldOpacity == 0)
        .opacity(vm.fixedAmountFieldOpacity)
    }
    
    private var rateField: some View {
        Section {
            HStack(spacing: 20) {
                TextField("", value: $vm.rate, format: .percent)
                    .focused($focusedField, equals: .rate)
                    .placeholder(when: vm.rate == nil) {
                        Text("Enter rate")
                            .opacity(0.6)
                    }
                    .font(FBFonts.kanitRegular(size: .body))
                    .itemOutlinedStyle()
                
                Text("OF")
                    .font(FBFonts.kanitMedium(size: .subheadline))
                    .opacity(0.6)
                
                TextField("", value: $vm.amount, format: .number)
                    .focused($focusedField, equals: .amount)
                    .placeholder(when: vm.amount == nil) {
                        Text("Enter amount")
                            .opacity(0.6)
                    }
                    .font(FBFonts.kanitRegular(size: .body))
                    .itemOutlinedStyle()
            }
        } header: {
            Text("Rate".uppercased())
                .font(FBFonts.kanitMedium(size: .subheadline))
                .opacity(0.6)
        }
        .isHidden(vm.rateFieldOpacity == 0, remove: vm.rateFieldOpacity == 0)
        .opacity(vm.rateFieldOpacity)
    }
    
    private var labelTextField: some View {
        Section {
            TextField("", text: $vm.label)
                .focused($focusedField, equals: .label)
                .placeholder(when: vm.label.isEmpty) {
                    Text("Enter label")
                        .opacity(0.6)
                }
                .font(FBFonts.kanitRegular(size: .body))
                .itemOutlinedStyle()
        } header: {
            Text("Label".uppercased())
                .font(FBFonts.kanitMedium(size: .subheadline))
                .opacity(0.6)
        }
    }
    
    private var doneBtn: some View {
        Button {
            dismiss()
        } label: {
            Text("Done")
                .font(FBFonts.kanitRegular(size: .body))
                .frame(maxWidth: .infinity)
                .itemFilledStyle()
        }
        .disabled(vm.shouldDisableDoneBtn)
        .buttonStyle(.plain)
        .padding()

    }
}
