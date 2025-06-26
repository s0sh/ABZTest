//
//  ABZTest_iOs_BihunApp.swift
//  ABZTest_iOs_Bihun
//
//  Created by Roman Bigun on 18.06.2025.
//

import SwiftUI
// swiftlint:disable type_name
@main
struct ABZTest_iOs_BihunApp: App {
    
    @StateObject var viewModel: UserViewModel = UserViewModel()
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(viewModel)
        }
    }
}
