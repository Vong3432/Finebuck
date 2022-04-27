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
    
    let calculationItem: BudgetItem?
    
    @State private var rateFieldOpacity: Double = 0
    @State private var fixedAmountFieldOpacity: Double = 1
    
    @State private var label = ""
    @State private var amount: Double? = nil
    @State private var rate: Double? = nil
    @State private var isCost = true
    @State private var budgetCalculateType: Budgeting.CalculateType = .fixed
    
    @FocusState private var focusedField: Field?
    
    init(calculationItem: BudgetItem? = nil) {
        self.calculationItem = calculationItem
    }
    
    var body: some View {
        ScrollView(.vertical) {
            
            VStack(alignment: .leading, spacing: 30) {
                Text("\(calculationItem == nil ? "Add" : "Edit")")
                    .font(FBFonts.kanitMedium(size: .title))
                content
                
                if focusedField != nil {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }.customTint(Color.theme.primary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(Color.theme.text)
        }
        .background(Color.theme.background)
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
        VStack(alignment: .leading, spacing: 25) {
            budgetPlanDetailFormType
            budgetPlanDetailFormCalculateType
            rateField
            fixedAmountField
            labelTextField
        }
        .onChange(of: budgetCalculateType) { newValue in
            if newValue == .fixed {
                rateFieldOpacity = 0
                fixedAmountFieldOpacity = 1
            } else {
                rateFieldOpacity = 1
                fixedAmountFieldOpacity = 0
            }
        }
    }
    
    private var budgetPlanDetailFormType: some View {
        Section {
            HStack {
                Button {
                    isCost = true
                } label: {
                    Text("Cost")
                        .padding()
                        .font(FBFonts.kanitSemiBold(size: .headline))
                }
                .frame(maxWidth: .infinity)
                .itemOutlinedStyle(borderColor: isCost ? Color.theme.primary : Color.theme.gray)
                
                
                Spacer()
                
                Button {
                    isCost = false
                } label: {
                    Text("Earning")
                        .padding()
                        .font(FBFonts.kanitSemiBold(size: .headline))
                }
                .frame(maxWidth: .infinity)
                .itemOutlinedStyle(borderColor: !isCost ? Color.theme.primary : Color.theme.gray)
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
                    budgetCalculateType = .fixed
                } label: {
                    Text(Budgeting.CalculateType.fixed.rawValue)
                        .padding()
                        .font(FBFonts.kanitSemiBold(size: .headline))
                }
                .frame(maxWidth: .infinity)
                .itemOutlinedStyle(borderColor: budgetCalculateType == .fixed ? Color.theme.primary : Color.theme.gray)
                
                
                Spacer()
                
                Button {
                    budgetCalculateType = .rate
                } label: {
                    Text(Budgeting.CalculateType.rate.rawValue)
                        .padding()
                        .font(FBFonts.kanitSemiBold(size: .headline))
                }
                .frame(maxWidth: .infinity)
                .itemOutlinedStyle(borderColor: budgetCalculateType == .rate ? Color.theme.primary : Color.theme.gray)
            }
        } header: {
            Text("Type".uppercased())
                .font(FBFonts.kanitMedium(size: .subheadline))
                .opacity(0.6)
        }
    }
    
    private var fixedAmountField: some View {
        Section {
//            CustomTextField(value: $amount, format: .percent)
//                .keyboardType(.decimalPad)
//                .itemOutlinedStyle()
            
            TextField("", value: $amount, format: .number)
                .keyboardType(.decimalPad)
                .focused($focusedField, equals: .amount)
                .placeholder(when: amount == nil) {
                    Text("Enter amount")
                        .opacity(0.6)
                }
                .font(FBFonts.kanitRegular(size: .body))
                .itemOutlinedStyle()
        } header: {
            Text("Amount".uppercased())
                .font(FBFonts.kanitMedium(size: .subheadline))
                .opacity(0.6)
        }
        .isHidden(fixedAmountFieldOpacity == 0, remove: fixedAmountFieldOpacity == 0)
        .opacity(fixedAmountFieldOpacity)
    }
    
    private var rateField: some View {
        Section {
            HStack(spacing: 20) {
                TextField("", value: $rate, format: .percent)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .rate)
                    .placeholder(when: rate == nil) {
                        Text("Enter rate")
                            .opacity(0.6)
                    }
                    .font(FBFonts.kanitRegular(size: .body))
                    .padding(.trailing)
                    .itemOutlinedStyle()
                    .fixedSize()
                
                Text("OF")
                    .font(FBFonts.kanitMedium(size: .subheadline))
                    .opacity(0.6)
                
                TextField("", value: $amount, format: .number)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .amount)
                    .placeholder(when: amount == nil) {
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
        .isHidden(rateFieldOpacity == 0, remove: rateFieldOpacity == 0)
        .opacity(rateFieldOpacity)
    }
    
    private var labelTextField: some View {
        Section {
            TextField("", text: $label)
                .focused($focusedField, equals: .label)
                .placeholder(when: label.isEmpty) {
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
}
