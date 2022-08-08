//
//  CloseBarItem.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 05/05/2022.
//

import SwiftUI

struct CloseBarItem: View {
    @Environment(\.dismiss) private var dismiss
    
    let text: String
    let onTap: (() -> Void)?
    
    init(text: String, onTap: (() -> Void)? = nil) {
        self.text = text
        self.onTap = onTap
    }
    
    var body: some View {
        Button {
            onTap?()
            dismiss()
        } label: {
            Text(text)
                .padding(.leading)
                .font(FBFonts.kanitRegular(size: .body))
                .foregroundColor(Color.theme.primary)
        }
    }
}

struct CloseBarItem_Previews: PreviewProvider {
    
    static var previews: some View {
        CloseBarItem(text: "Save")
    }
}
