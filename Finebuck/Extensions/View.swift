//
//  View.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 23/04/2022.
//

import Foundation
import SwiftUI

extension View {
    func loadSVG(_ image: String) -> Image {
        let uiimg = UIImage(named: image)
        
        guard let uiimg = uiimg else { return Image(systemName: "xmark") }
        uiimg.withRenderingMode(.alwaysTemplate)
        
        let img = Image(uiImage: uiimg)
        return img
    }
    
    
    /// Hide or show the view based on a boolean value. [View stackoverflow](https://stackoverflow.com/a/59228385/10868150)
    ///
    /// Example for visibility:
    ///
    ///     Text("Label")
    ///         .isHidden(true)
    ///
    /// Example for complete removal:
    ///
    ///     Text("Label")
    ///         .isHidden(true, remove: true)
    ///
    /// - Parameters:
    ///   - hidden: Set to `false` to show the view. Set to `true` to hide the view.
    ///   - remove: Boolean value indicating whether or not to remove the view.
    @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }
    
    /// Change placeholder text color. [View stackoverflow](https://stackoverflow.com/a/57715771)
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
            
            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }
}


