//
//  TemplateCardView.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 23/04/2022.
//

import SwiftUI

struct TemplateCardView: View {
    let template: Template
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(template.title)
                .font(FBFonts.kanitSemiBold(size: .subheadline))
            Text(template.description)
                .font(FBFonts.kanitRegular(size: .caption))
                .opacity(0.6)
            
            Spacer()
            
            Text(template.category.rawValue)
                .font(FBFonts.kanitBold(size: .caption2))
                .opacity(0.6)
        }
        .frame(height: 100)
        .frame(maxWidth: .infinity, alignment: .leading)
        .itemOutlinedStyle()
    }
}

struct TemplateCardView_Previews: PreviewProvider {
    static var previews: some View {
        TemplateCardView(template: .mockedTemplates[0])
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
