//
//  UserRowView.swift
//  ABZTest_iOs_Bihun
//
//  Created by Roman Bigun on 21.06.2025.
//
import SwiftUI

struct UserRowView: View {
    
    let user: User
    
    @StateObject private var imageLoader: OptionalImageLoader
    
    init(user: User) {
        self.user = user
        _imageLoader = StateObject(wrappedValue: OptionalImageLoader(url: URL(string: user.photo)))
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            if let image = imageLoader.image {
                
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } else {
                ProgressView()
                    .frame(width: 50, height: 50)
            }
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(.custom("Nunito-Sans", size: 18))
                    .fontWeight(.light)
                    .foregroundStyle(.black).opacity(0.87)
                Text(user.position)
                    .font(.custom("Nunito-Sans", size: 14))
                    .foregroundStyle(.black).opacity(0.60)
                    .fontWeight(.light)
                Text(user.email)
                    .font(.custom("Nunito-Sans", size: 14))
                    .fontWeight(.light)
                    .foregroundStyle(.black).opacity(0.87)
                Text(user.phone)
                    .font(.custom("Nunito-Sans", size: 14))
                    .fontWeight(.light)
                    .foregroundStyle(.black).opacity(0.87)
            }
        }
        .padding(.vertical, 8)
    }
}
