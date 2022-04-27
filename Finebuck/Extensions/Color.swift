//
//  Color.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 23/04/2022.
//

import Foundation
import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    let text = Color("TextColor")
    let gray = Color("GrayColor")
    let primary = Color("PrimaryColor")
    let background = Color("BgColor")
}
