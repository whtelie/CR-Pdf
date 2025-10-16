//
//  PDFCreatorService.swift
//  CR Pdf
//
//  Created by Ivan Mareev on 16.10.2025.
//

import UIKit
import PDFKit

enum PDFCreator {
    static func createPDF(from images: [UIImage], fileName: String) -> URL? {
        let tempDireciry = FileManager.default.temporaryDirectory
        let pdfURL = tempDireciry.appendingPathComponent("\(fileName).pdf")
        
        let pdfDocument = PDFDocument()
        
        for (i, image) in images.enumerated() {
            if let pdfPage = PDFPage(image: image) {
                pdfDocument.insert(pdfPage, at: i)
            }
        }
        //TODO: разобраться с удалением временного файла
        guard pdfDocument.write(to: pdfURL) else {
            return nil
        }
        
        return pdfURL
    }
    
    static func createPDFFromURLs(_ urls: [URL], fileName: String) -> URL? {
        var images: [UIImage] = []
        
        for url in urls {
            guard url.startAccessingSecurityScopedResource() else { continue }
            defer { url.stopAccessingSecurityScopedResource() }
            
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                images.append(image)
            }
        }
        
        return createPDF(from: images, fileName: fileName)
    }
}
