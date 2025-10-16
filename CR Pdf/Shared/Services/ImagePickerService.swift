//
//  ImagePickerService.swift
//  CR Pdf
//
//  Created by Ivan Mareev on 16.10.2025.
//

import SwiftUI
import PhotosUI
import Combine

@MainActor
final class ImagePickerService: ObservableObject {
    @Published var selectedImages: [UIImage] = []
    
    func reset() {
        selectedImages.removeAll()
    }
}


extension NSItemProvider {
    func loadImage() async throws -> UIImage {
        try await withCheckedThrowingContinuation { continuation in
            self.loadObject(ofClass: UIImage.self) { object, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let image = object as? UIImage else {
                    continuation.resume(throwing: NSError(domain: "InvalidType", code: -1))
                    return
                }
                continuation.resume(returning: image)
            }
        }
    }
}

