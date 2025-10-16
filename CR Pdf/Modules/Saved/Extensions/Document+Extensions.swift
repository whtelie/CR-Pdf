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
              let fileURL = fileURL else {
            throw DocumentError.invalidDocument
        }
        
        return DocumentModel(
            id: id,
            name: name,
            creationDate: creationDate,
            fileURL: fileURL,
            fileSize: fileSize ?? "Unknown size",
            pageCount: pageCount?.intValue
        )
    }
    
    func copyFile(from sourceURL: URL) throws {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentsDirectory
            .appendingPathComponent("PDFs")
            .appendingPathComponent("\(id?.uuidString ?? UUID().uuidString).pdf")
        
        try fileManager.createDirectory(
            at: destinationURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        
        if fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.removeItem(at: destinationURL)
        }
        
        try fileManager.copyItem(at: sourceURL, to: destinationURL)
        self.fileURL = destinationURL
        updateFileInfo()
    }
    
    func deleteFile() {
        guard let fileURL = fileURL else { return }
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    private func updateFileInfo() {
        guard let fileURL = fileURL else { return }
        
        // Обновляем размер
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            if let fileSize = attributes[.size] as? Int64 {
                self.fileSize = ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
            }
        } catch {
            print("Error getting file size: \(error)")
        }
        
        // Обновляем кол-во страниц
        if let pdf = PDFDocument(url: fileURL) {
            self.pageCount = NSNumber(value: pdf.pageCount)
        }
    }
}
