//
//  ButtonModifier.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 23/04/2022.
//

import Foundation
import SwiftUI

struct ItemFilledViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.theme.gray)
            .cornerRadius(12)
    }
}

struct ItemOutlinedViewModifier: ViewModifier {
    let borderColor: Color
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.theme.background)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(borderColor, lineWidth: 3)
            )
    }
}

extension View {
    func itemFilledStyle() -> some View {
        return modifier(ItemFilledViewModifier())
    }
    
    func itemOutlinedStyle(borderColor: Color = Color.theme.gray) -> some View {
        return modifier(ItemOutlinedViewModifier(borderColor: borderColor))
    }
}
