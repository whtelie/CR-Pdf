//
//  PDFEditorViewModel.swift
//  CR Pdf
//
//  Created by Ivan Mareev on 16.10.2025.
//


import Foundation
import SwiftUI
import Combine
import PDFKit

final class PDFEditorViewModel: ObservableObject {
    @Published var document: DocumentModel
    @Published var editedPDFData: Data?
    @Published var isProcessing = false
    @Published var errorMessage: String?
    
    var onSave: (() -> Void)?
    
    private let pdfEditor: PDFEditorService
    private let documentRepository: DocumentRepository
    
    init(document: DocumentModel,
         documentRepository: DocumentRepository,
         pdfEditor: PDFEditorService) {
        self.document = document
        self.documentRepository = documentRepository
        self.pdfEditor = pdfEditor
    }
    
    var pageCount: Int {
        let data = editedPDFData ?? document.pdfData
        return PDFDocument(data: data)?.pageCount ?? 0
    }

    
    func getPageThumbnail(for pageIndex: Int, size: CGSize) -> UIImage? {
        pdfEditor.generateThumbnail(for: editedPDFData ?? document.pdfData, pageIndex: pageIndex, size: size)
    }
    
    func rotateAllPages() {
        isProcessing = true
        errorMessage = nil
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            do {
                let data = try self.pdfEditor.rotateAllPages(in: self.editedPDFData ?? self.document.pdfData)
                DispatchQueue.main.async {
                    self.editedPDFData = data
                    self.isProcessing = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to rotate pages: \(error.localizedDescription)"
                    self.isProcessing = false
                }
            }
        }
    }
    
    func rotatePage(at index: Int) {
        isProcessing = true
        errorMessage = nil
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            do {
                let data = try self.pdfEditor.rotatePage(at: index, in: self.editedPDFData ?? self.document.pdfData)
                DispatchQueue.main.async {
                    self.editedPDFData = data
                    self.isProcessing = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to rotate page: \(error.localizedDescription)"
                    self.isProcessing = false
                }
            }
        }
    }
    
    func removePage(at index: Int) {
        isProcessing = true
        errorMessage = nil
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            do {
                let data = try self.pdfEditor.removePage(at: index, from: self.editedPDFData ?? self.document.pdfData)
                DispatchQueue.main.async {
                    withAnimation {
                        self.editedPDFData = data
                        self.objectWillChange.send()
                        self.isProcessing = false
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to remove page: \(error.localizedDescription)"
                    self.isProcessing = false
                }
            }
        }
    }
    
    func saveChanges() throws {
        guard let data = editedPDFData else { throw PDFEditorError.noChanges }
        try documentRepository.update(document, with: data)
        onSave?()
    }
}
