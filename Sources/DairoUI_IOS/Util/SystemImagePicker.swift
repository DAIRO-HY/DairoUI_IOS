//
//  SystemImagePicker.swift
//  DairoImageCrop
//
//  Created by zhoulq on 2024/03/17.
//
#if os(iOS)
import SwiftUI
import UIKit

/**
 * 图片选择器
 */
public struct SystemUIImagePicker: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) var presentationMode
    
    let callback:(_ image: UIImage?)->Void
    
    public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: SystemUIImagePicker
        
        init(_ parent: SystemUIImagePicker) {
            self.parent = parent
        }
        
        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let uiImage = info[.originalImage] as? UIImage
            self.parent.callback(uiImage)
            self.parent.presentationMode.wrappedValue.dismiss()
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public func makeUIViewController(context: UIViewControllerRepresentableContext<SystemUIImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<SystemUIImagePicker>) {

    }
}
#endif
