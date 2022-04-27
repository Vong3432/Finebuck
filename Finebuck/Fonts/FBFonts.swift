//
//  FBFont.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 23/04/2022.
//

import Foundation
import SwiftUI

struct FBFonts {
    
    static func kanitBlack(size: Double) -> Font {
        return Font.custom("Kanit-Black", size: size)
    }

    static func kanitBold(size: Double) -> Font{
        return Font.custom("Kanit-Bold", size: size)
    }

    static func kanitExtraBold(size: Double) -> Font{
        return Font.custom("Kanit-ExtraBold", size: size)
    }
    
    static func kanitMedium(size: Double) -> Font{
        return Font.custom("Kanit-Medium", size: size)
    }
    
    static func kanitRegular(size: Double) -> Font{
        return Font.custom("Kanit-Regular", size: size)
    }
    
    static func kanitSemiBold(size: Double) -> Font {
        return Font.custom("Kanit-SemiBold", size: size)
    }

}

struct FBFontsViewModifier: ViewModifier {
    let fontType: FBFonts
    
    func body(content: Content) -> some View {
        content
            .font(FBFonts.kanitRegular(size: 12))
    }
}


enum FontSize {
    case largeTitle
    case title
    case title2
    case title3
    case headline, body
    case subheadline, callout
    case footnote
    case caption
    case caption2
    case unknown
    
    var size: Double {
        switch self {
        case .largeTitle: return 34
        case .title: return 28
        case .title2: return 22
        case .title3: return 20
        case .headline, .body: return 17
        case .callout: return 16
        case .subheadline: return 15
        case .footnote: return 13
        case .caption: return 12
        case .caption2: return 10
        case .unknown:
            fallthrough
        @unknown default:
            return 8
        }
    }
}

// - MARK: Double Extension
extension Double {
    static func fontSize(_ font: FontSize) -> Double {
        return font.size
    }
    
    static let largeTitle = FontSize.largeTitle.size
    static let title = FontSize.title.size
    static let title2 = FontSize.title2.size
    static let title3 = FontSize.title3.size
    static let headline = FontSize.headline.size
    static let body = FontSize.body.size
    static let subheadline = FontSize.subheadline.size
    static let callout = FontSize.callout.size
    static let footnote = FontSize.footnote.size
    static let caption = FontSize.caption.size
    static let caption2 = FontSize.caption2.size
    static let unknown = FontSize.unknown.size
}

