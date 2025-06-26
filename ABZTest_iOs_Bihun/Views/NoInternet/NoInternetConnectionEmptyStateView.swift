//
//  NoInternetConnectionEmptyStateView.swift
//  ABZTest_iOs_Bihun
//
//  Created by Roman Bigun on 19.06.2025.
//

import SwiftUI

struct NoInternetConnectionEmptyStateView: View {
    @EnvironmentObject var viewModel: UserViewModel
    
    var body: some View {
        ZStack {
            
            VStack(spacing: 24) {
                Image("noInternet")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200, alignment: .center)
                    .padding([.vertical, .horizontal])
                Text("There is no internet connection")
                    .font(.custom("Nunito-Sans", size: 18))
                    .fontWeight(.light)
                    .foregroundStyle(.black).opacity(0.87)
                Button {
                    viewModel.loadUsers()
                } label: {
                    Text("Try again")
                        .font(.custom("Nunito-Sans", size: 18))
                        .fontWeight(.light)
                        .foregroundStyle(.black).opacity(0.87)
                        .frame(width: 150, height: 48)
                        .buttonBorderShape(.capsule)
                        .background(
                            Capsule()
                                .fill(AppConstants.Colors.Main.primary)
                        )
                }
                
            }
        }
    }
}
