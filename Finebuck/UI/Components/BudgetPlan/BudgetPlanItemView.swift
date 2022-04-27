//
//  BudgetPlanItemView.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 24/04/2022.
//

import SwiftUI

struct BudgetPlanItemView: View {
    let budgeting: Budgeting
    
    var body: some View {
        HStack(spacing: 14) {
            Text(budgeting.title.firstChar())
                .font(FBFonts.kanitBold(size: .title2))
                .foregroundColor(Color.theme.text)
                .padding(.horizontal)
                .background {
                    Circle().fill(Color.theme.primary)
                }
            Text(budgeting.title)
                .font(FBFonts.kanitRegular(size: .body))
            Spacer()
        }.itemFilledStyle()
    }
}

struct BudgetPlanItemView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetPlanItemView(budgeting: .mockBudgetingItems[0])
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}
