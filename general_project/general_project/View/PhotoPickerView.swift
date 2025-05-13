//
//  PhotoPickerView.swift
//  general_project
//
//  Created by 이상엽 on 5/7/25.
//

import SwiftUI
import PhotosUI

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 0 // 0 = unlimited
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        init(_ parent: PhotoPicker) { self.parent = parent }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            for result in results {
                let id = result.itemProvider.registeredTypeIdentifiers.first ?? "public.data"
                result.itemProvider.loadDataRepresentation(forTypeIdentifier: id) { data, error in
                    if let data, let img = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.parent.images.append(img)
                        }
                    } else {
                        print("이미지 로드 실패:", error?.localizedDescription ?? "")
                    }
                }
            }
        }
    }
}
