//
//  CloseBarItem.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 05/05/2022.
//

import SwiftUI

struct CloseBarItem: View {
    @Binding var dismiss: DismissAction
    let text: String
    
    var body: some View {
        Button {
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
    
    @Environment(\.dismiss) private static var dismiss
    
    static var previews: some View {
        CloseBarItem(dismiss: .constant(dismiss), text: "Save")
    }
}
