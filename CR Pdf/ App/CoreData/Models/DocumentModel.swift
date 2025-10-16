//
//  DocumentModel.swift
//  CR Pdf
//
//  Created by Ivan Mareev on 15.10.2025.
//


import Foundation
import UIKit
import PDFKit

public struct DocumentModel: Identifiable, Equatable {
    public let id: UUID
    let name: String
    let creationDate: Date
    let pdfData: Data
    let fileSize: String
    let pageCount: Int?
    let thumbnail: UIImage?
    
    var calculatedFileSize: String {
        ByteCountFormatter.string(fromByteCount: Int64(pdfData.count), countStyle: .file)
    }
      
    var calculatedPageCount: Int {
        PDFDocument(data: pdfData)?.pageCount ?? 0
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: creationDate)
    }
}
