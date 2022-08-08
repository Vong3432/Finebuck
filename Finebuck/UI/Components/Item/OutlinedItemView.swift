//
//  BudgetCalculateItemView.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 24/04/2022.
//

import SwiftUI

struct OutlinedItemView: View {
    
    let title: String
    let subtitle: String?
    let trailing: String
    
    init(title: String, subtitle: String? = nil, trailing: String) {
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(FBFonts.kanitMedium(size: .headline))
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(FBFonts.kanitRegular(size: .caption))
                        .opacity(0.6)
                }
            }
            Spacer()
            Text(trailing)
                .font(FBFonts.kanitSemiBold(size: .subheadline))
        }
        .multilineTextAlignment(.leading)
        .itemOutlinedStyle()
    }
}

struct OutlinedItemView_Previews: PreviewProvider {
    static let mocked = Budgeting.mockBudgetingItems[0].costs[0]
    
    static var previews: some View {
        OutlinedItemView(
            title: mocked.title,
            subtitle: mocked.type.rawValue,
            trailing: mocked.formattedValue
        )
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}
