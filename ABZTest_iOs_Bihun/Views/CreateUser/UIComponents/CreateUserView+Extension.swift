//
//  File.swift
//  ABZTest_iOs_Bihun
//
//  Created by Roman Bigun on 21.06.2025.
//

import SwiftUI

enum TextFieldType: String {
    case name
    case email
    case phone
    
    var title: String {
        switch self {
            
        case .name:
            "Your name"
        case .email:
            "Email"
        case .phone:
            "Phone"
        }
    }
}

extension CreateUserView {
    @ViewBuilder
    func forms() -> some View {
        VStack(spacing: 40) {
            VStack {
                HStack {
                    TextField("Your name", text: $viewModel.name)
                        .padding(.leading, 26)
                        .keyboardType(.default)
                        .overlay (
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(viewModel.hasAttemptedSignUp && !viewModel.nameFieldValid ? Color.red : Color.gray.opacity(0.4), lineWidth: 1)
                                .frame(width: UIScreen.main.bounds.width * 0.9,height: 56)
                        )
                    
                }
                if viewModel.hasAttemptedSignUp && !viewModel.nameFieldValid {
                    requiredFieldView()
                        .padding(.top, 25)
                }
            }
            VStack {
                HStack {
                    TextField("Email", text: $viewModel.email)
                        .padding(.leading, 26)
                        .keyboardType(.default)
                        .overlay (
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(viewModel.hasAttemptedSignUp && !viewModel.emailFieldValid ? Color.red : Color.gray.opacity(0.4), lineWidth: 1)
                                .frame(width: UIScreen.main.bounds.width * 0.9,height: 56)
                        )
                    
                }
                if viewModel.hasAttemptedSignUp && !viewModel.emailFieldValid {
                    requiredFieldView()
                        .padding(.top, 25)
                }
            }
            VStack {
                HStack {
                    TextField("Phone", text: $viewModel.phone)
                        .padding(.leading, 26)
                        .keyboardType(.default)
                        .overlay (
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(viewModel.hasAttemptedSignUp && !viewModel.phoneFieldValid ? Color.red : Color.gray.opacity(0.4), lineWidth: 1)
                                .frame(width: UIScreen.main.bounds.width * 0.9,height: 56)
                        )
                    
                }
                if viewModel.hasAttemptedSignUp && !viewModel.phoneFieldValid {
                    requiredFieldView()
                        .padding(.top, 25)
                } else {
                    VStack {
                        HStack {
                                Text("+38 (XXX) XXX XX XX")
                                    .foregroundColor(Color.gray.opacity(0.4))
                            Spacer()
                        }
                        Spacer()
                    }
                    .padding()
                    .padding(.leading, 10)
                }
            }
        }
    }
    @ViewBuilder
    func requiredFieldView() -> some View {
        HStack {
            Text("Required fields")
                .foregroundColor(.red)
                .font(.custom("Nunito-Sans", size: 12))
                .fontWeight(.light)
                .foregroundStyle(.black).opacity(0.87)
                .padding(.leading, 10)
            Spacer()
        }
        .frame(width: UIScreen.main.bounds.width * 0.9, height: 1)
    }
}
