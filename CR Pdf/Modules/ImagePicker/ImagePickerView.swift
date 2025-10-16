//
//  ImagePickerView.swift
//  CR Pdf
//
//  Created by Ivan Mareev on 16.10.2025.
//

import SwiftUI
import PhotosUI

struct ImagePickerView: UIViewControllerRepresentable {
    @ObservedObject var service: ImagePickerService
    var selectionLimit: Int = 0
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = selectionLimit
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePickerView
        
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            Task {
                var images: [UIImage] = []
                for result in results {
                    if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                        do {
                            let image = try await result.itemProvider.loadImage()
                            images.append(image)
                        } catch {
                            print("Ошибка загрузки изображения: \(error)")
                        }
                    }
                }
                await MainActor.run {
                    parent.service.selectedImages.append(contentsOf: images)
                }
            }
        }
    }
}
