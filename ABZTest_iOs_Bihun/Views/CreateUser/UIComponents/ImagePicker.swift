//
//  ImagePicker.swift
//  ABZTest_iOs_Bihun
//
//  Created by Roman Bigun on 21.06.2025.
//
import SwiftUI
import UniformTypeIdentifiers

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var imagePickerError: String
    @Binding var showImagePickerError: Bool
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.mediaTypes = [UTType.image.identifier]
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(self)
        coordinator.pickerError = { show, message in
            self.imagePickerError = message
            self.showImagePickerError = show
        }
        return coordinator
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var pickerError: ((Bool, String) -> Void?)? = nil
        let parent: ImagePicker
        let maxFileSize: Int = 5 * 1024 * 1024 // 5MB in bytes
        let requiredSize = CGSize(width: 70, height: 70)
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
       
        func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                picker.dismiss(animated: true)
                
                guard let imageUrl = info[.imageURL] as? URL else {
                    showError(message: "No image URL found")
                    return
                }
                
                // 1. Check file type
                guard imageUrl.pathExtension.lowercased() == "jpg" ||
                      imageUrl.pathExtension.lowercased() == "jpeg" else {
                    showError(message: "Only JPG/JPEG are allowed")
                    return
                }
                
                // 2. Check file size
                do {
                    let resources = try imageUrl.resourceValues(forKeys: [.fileSizeKey])
                    guard let fileSize = resources.fileSize, fileSize < maxFileSize else {
                        showError(message: "File size must be less than 5MB")
                        return
                    }
                } catch {
                    showError(message: "Could not determine file size")
                    return
                }
                
                // 3. Check image dimensions
                guard let image = info[.originalImage] as? UIImage else {
                    showError(message: "Could not load image")
                    return
                }
                
                if image.size != requiredSize {
                    showError(message: "Image must be exactly 70x70 pixels")
                    return
                }
                
                // If all checks pass, use the image
                handleValidImage(image)
            }
            
            func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                picker.dismiss(animated: true)
            }
            
            private func handleValidImage(_ image: UIImage) {
                parent.image = image
                parent.dismiss()
            }
            
            private func showError(message: String) {
                pickerError?(true, message)
            }
    }
}
