import SwiftUI

#Preview {
    CreateUserView()
        .environmentObject(UserViewModel())
}

struct CreateUserView: View {
    
    @EnvironmentObject var viewModel: UserViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var photo: UIImage?
    
    @State var imagePickerError: String = ""
    @State var showImagePickerError: Bool = false
    
    @State private var showingImagePicker = false
    
    var body: some View {
        VStack {
            CommonHeader(requestType: "POST")
            ScrollView {
                VStack {
                    forms()
                        .padding(.top, 25)
                    
                    //MARK: - Position Section
                    HStack {
                        Text("Select your position")
                            .padding(.leading, 16)
                        Spacer()
                    }
                    VStack {
                        ForEach(viewModel.positions) { position in
                            HStack {
                                // Radio button
                                Image(systemName: viewModel.selectedPositionId == position.id ? "largecircle.fill.circle" : "circle")
                                    .foregroundColor(AppConstants.Colors.Button.secondaryDark)
                                
                                // Position name
                                Text(position.name)
                                    .font(.headline)
                                
                                Spacer()
                            }
                            .contentShape(Rectangle()) // Makes entire row tappable
                            .onTapGesture {
                                viewModel.selectedPositionId = position.id
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                        }
                    }
                    .overlay {
                        if viewModel.isLoading && viewModel.positions.isEmpty {
                            ProgressView()
                        }
                    }
                    //MARK: -  Image loader
                    VStack {
                        HStack {
                            Text("Upload your photo")
                                .foregroundColor(!viewModel.photoFieldValid ? Color.red : Color.gray.opacity(0.4))
                            Spacer()
                            if let photo = photo {
                                Image(uiImage: photo)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: photo == nil ? 200 : 56)
                            }
                            Spacer()
                            Button(photo == nil ? "Upload" : "Change Photo") {
                                showingImagePicker = true
                            }
                            
                            
                        }
                        .padding()
                        .frame(width: UIScreen.main.bounds.width * 0.9)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(viewModel.hasAttemptedSignUp && !viewModel.photoFieldValid ? Color.red : Color.gray.opacity(0.4), lineWidth: 1)
                        )
                        
                        if viewModel.hasAttemptedSignUp && !viewModel.photoFieldValid {
                            requiredFieldView()
                        }
                    }
                    
                    Button {
                        saveUser()
                    } label: {
                        Text("Sign up")
                            .font(.custom("Nunito-Sans", size: 18))
                            .fontWeight(.light)
                            .foregroundStyle(.black).opacity(0.87)
                            .frame(width: 150, height: 48)
                            .buttonBorderShape(.capsule)
                            .background(
                                Capsule()
                                    .fill(AppConstants.Colors.Button.normal)
                            )
                    }
                    .padding(.top, 25)
                }
            }
            .accentColor(AppConstants.Colors.Button.secondaryDark)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.loadPositions()
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $photo,
                            imagePickerError: $imagePickerError,
                            showImagePickerError: $showImagePickerError)
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .alert("Image Picker Error", isPresented: $showImagePickerError) {
                Button("OK") {
                    showImagePickerError = false
                }
            } message: {
                Text(imagePickerError)
            }
        }
    }
    
    private func saveUser() {
        let imageData = photo?.jpegData(compressionQuality: 0.5)
        viewModel.createUser(photoData: imageData)
        if viewModel.nameFieldValid && viewModel.emailFieldValid && viewModel.phoneFieldValid && viewModel.photoFieldValid {
            dismiss()
        }
    }
}
