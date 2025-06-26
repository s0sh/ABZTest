//
//  AppConstants.swift
//  ABZTest_iOs_Bihun
//
//  Created by Roman Bigun on 18.06.2025.
//

import SwiftUI

enum AppStates {
    case noInternet
    case noUsers
    case registeredSuccessfully
}

enum ButtonState {
    case normal
    case pressed
    case disabled
    
    var background: Color {
        switch self {
        case .normal:
            AppConstants.Colors.Button.normal
        case .pressed:
            AppConstants.Colors.Button.pressed
        case .disabled:
            AppConstants.Colors.Button.disabled
        }
    }
}

enum AppConstants {
    enum Colors {
        enum Main {
            static let primary: Color = Color(hex: "#F4E041")
            static let secondary: Color = Color(hex: "#F4E041")
        }
        enum Button {
            static let normal: Color = Main.primary
            static let disabled: Color = Color(hex: "#DADADA")
            static let pressed: Color = Color(hex: "#FFC700")
            static let secondaryDark: Color = Color(hex: "#009BBD")
            static let secondaryDisabled: Color = Color(hex: "#DADADA")
            static let secondaryDarkBG: Color = Color(hex: "#00BDD3").opacity(0.1)
        }
    }
}
