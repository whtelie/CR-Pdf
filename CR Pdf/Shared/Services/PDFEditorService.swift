//
//  PDFEditorService.swift
//  CR Pdf
//
//  Created by Ivan Mareev on 16.10.2025.
//


import Foundation
import PDFKit
import UIKit

final class PDFEditorService {
    func rotateAllPages(in data: Data) throws -> Data {
        guard let pdf = PDFDocument(data: data) else {
            throw PDFEditorError.invalidPDFData
        }
        
        for i in 0..<pdf.pageCount {
            if let page = pdf.page(at: i) {
                let currentRotation = page.rotation
                page.rotation = (currentRotation + 90) % 360
            }
        }
        
        guard let rotatedData = pdf.dataRepresentation() else {
            throw PDFEditorError.failedToGenerateData
        }
        
        return rotatedData
    }
    
    func removePage(at index: Int, from data: Data) throws -> Data {
        guard let pdf = PDFDocument(data: data) else {
            throw PDFEditorError.invalidPDFData
        }
        
        guard index >= 0, index < pdf.pageCount else {
            throw PDFEditorError.invalidPageIndex
        }
        
        pdf.removePage(at: index)
        
        guard let updatedData = pdf.dataRepresentation() else {
            throw PDFEditorError.failedToGenerateData
        }
        
        return updatedData
    }
    
    func generateThumbnail(for data: Data, pageIndex: Int, size: CGSize) -> UIImage? {
        guard let pdf = PDFDocument(data: data),
              pageIndex >= 0, pageIndex < pdf.pageCount,
              let page = pdf.page(at: pageIndex) else {
            return nil
        }
        
        return page.thumbnail(of: size, for: .cropBox)
    }
}

enum PDFEditorError: Error {
    case invalidPDFData
    case invalidPageIndex
    case failedToGenerateData
    case noChanges
}
