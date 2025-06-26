//
//  CommonHeader.swift
//  ABZTest_iOs_Bihun
//
//  Created by Roman Bigun on 23.06.2025.
//

import SwiftUI

struct CommonHeader: View {
    var requestType: String = "GET"
    var body: some View {
        Text("Working with \(requestType) request")
            .font(.custom("Nunito-Sans", size: 18))
            .fontWeight(.light)
            .foregroundStyle(.black).opacity(0.87)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                AppConstants.Colors.Main.primary
            )
    }
}

