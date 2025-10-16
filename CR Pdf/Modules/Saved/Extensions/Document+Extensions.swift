//
//  Document+Extensions.swift
//  CR Pdf
//
//  Created by Ivan Mareev on 15.10.2025.
//

import Foundation
import CoreData
import PDFKit

extension Document {
    func toDomainModel() throws -> DocumentModel {
        guard let id = id,
              let name = name,
              let creationDate = creationDate,
              let pdfData = pdfData else {
            throw DocumentError.invalidDocument
        }
        
        let calculatedFileSize: String
        if let fileSize = fileSize {
            calculatedFileSize = fileSize
        } else {
            calculatedFileSize = ByteCountFormatter.string(fromByteCount: Int64(pdfData.count), countStyle: .file)
        }
        
        let thumbnailImage: UIImage?
        if let thumbnailData = thumbnailData {
            thumbnailImage = UIImage(data: thumbnailData)
        } else {
            thumbnailImage = nil
        }
        
        return DocumentModel(
            id: id,
            name: name,
            creationDate: creationDate,
            pdfData: pdfData,
            fileSize: calculatedFileSize ?? "Unknown size",
            pageCount: PDFDocument(data: pdfData)?.pageCount,
            thumbnail: thumbnailImage
        )
    }
    
    func copyFile(from sourceURL: URL) throws {
        let isSecurityScoped = sourceURL.startAccessingSecurityScopedResource()
        defer { if isSecurityScoped { sourceURL.stopAccessingSecurityScopedResource() } }

        let data = try Data(contentsOf: sourceURL)
        self.pdfData = data
 
        self.fileSize = ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file)
        self.pageCount = NSNumber(value: PDFDocument(data: data)?.pageCount ?? 0)
    }
}
