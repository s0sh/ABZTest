//
//  NoUsersEmptyStateView.swift
//  ABZTest_iOs_Bihun
//
//  Created by Roman Bigun on 21.06.2025.
//


import SwiftUI

struct NoUsersEmptyStateView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image("noUsers")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200, alignment: .center)
                .padding([.vertical, .horizontal])
            Text("There are no users yet")
                .font(.custom("Nunito-Sans", size: 18))
                .fontWeight(.light)
                .foregroundStyle(.black).opacity(0.87)
            
        }
    }
}
