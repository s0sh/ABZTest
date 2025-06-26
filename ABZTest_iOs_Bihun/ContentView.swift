//
//  ContentView.swift
//  ABZTest_iOs_Bihun
//
//  Created by Roman Bigun on 18.06.2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: UserViewModel
    var body: some View {
        TabView {
            Tab("Users", systemImage: "person.3.fill") {
                UserListView()
                    .environmentObject(viewModel)
            }
            Tab("Sign up", systemImage: "person.crop.circle.fill.badge.plus") {
                CreateUserView()
                    .environmentObject(viewModel)
            }
        }
        .preferredColorScheme(.light)
        .environmentObject(viewModel)
        .accentColor(AppConstants.Colors.Button.secondaryDark)
    }
}

#Preview {
    ContentView()
}
