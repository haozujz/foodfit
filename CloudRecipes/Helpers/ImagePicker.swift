//
//  ImagePicker.swift
//  CloudRecipes
//
//  Created by Joseph Zhu on 25/12/2022.
//

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var pickedImage: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewControler: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(imagePicker: self)
    }
    
    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let imagePicker: ImagePicker
        
        init(imagePicker: ImagePicker) {
            self.imagePicker = imagePicker
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.editedImage] as? UIImage {
                guard let data = image.jpegData(compressionQuality: 0.2), let compressedImage = UIImage(data: data) else {return}
                
                let croppedImage = compressedImage.cropImageToSquare()
                //let resizedImage = croppedImage.scalePreservingAspectRatio(targetSize: CGSize(width: 200, height: 200))
                //imagePicker.pickedImage = resizedImage
                //imagePicker.pickedImage = compressedImage
                imagePicker.pickedImage = croppedImage
            } else {
                print("ImagePicker error")
            }
            picker.dismiss(animated: true)
        }
    }
    
}

extension UIImage {
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )

        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        
        return scaledImage
    }
    
    func cropImageToSquare() -> UIImage {
        var imageHeight = self.size.height
        var imageWidth = self.size.width

        if imageHeight > imageWidth {
            imageHeight = imageWidth
        }
        else {
            imageWidth = imageHeight
        }

        let size = CGSize(width: imageWidth, height: imageHeight)

        let refWidth : CGFloat = CGFloat(self.cgImage!.width)
        let refHeight : CGFloat = CGFloat(self.cgImage!.height)

        let x = (refWidth - size.width) / 2
        let y = (refHeight - size.height) / 2

        let cropRect = CGRect(x: x, y: y, width: size.height, height: size.width)
        if let imageRef = self.cgImage!.cropping(to: cropRect) {
            return UIImage(cgImage: imageRef, scale: 0, orientation: self.imageOrientation)
        }

        return self
    }
}


