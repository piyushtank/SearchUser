//
//  Constants.swift
//  SearchUser
//

import SwiftUI

struct Constants {
    struct General {
        static let cornerRadius: CGFloat = 4.0
        static let padding: CGFloat = 16.0
        static let avatarWidth: CGFloat = 28.0
        static let avatarHeight: CGFloat = 28.0
        static let smallSpacerWidth: CGFloat = 12.0
        static let largeSpacerWidth: CGFloat = 8.0
        static let rowHeight: CGFloat = 44.0
    }
    
    struct Fonts {
        static let displayNameFont: Font = .custom("Lato-Bold", size: 16)
        static let userNameFont: Font = .custom("Lato-Regular", size: 16)
    }
    
    struct Colors {
        static let displayNameColor: Color = Color(hex: "1D1C1D")
        static let userNameColor: Color = Color(hex: "616061")
        static let backgroundColor: Color = Color(hex: "FFFFFF")
    }
}
