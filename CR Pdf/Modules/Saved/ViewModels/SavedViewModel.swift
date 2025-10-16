//
//  SavedViewModel.swift
//  CR Pdf
//
//  Created by Ivan Mareev on 15.10.2025.
//

import Foundation
import Combine
import UIKit

final class SavedViewModel: ObservableObject {
    @Published var documents: [DocumentModel] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var isCreatingPDF = false
    
    private let repository: DocumentRepository
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: DocumentRepository) {
        self.repository = repository
    }
    
    func loadDocuments() {
        isLoading = true
        errorMessage = nil
        
        do {
            documents = try repository.fetchAllDocuments()
            isLoading = false
        } catch {
            errorMessage = "Failed to load documents: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func addDocument(from url: URL, isSecurityScoped: Bool = false) {
        if isSecurityScoped {
            guard url.startAccessingSecurityScopedResource() else {
                errorMessage = "Cannot access the selected file"
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let newDocument = try repository.saveDocument(from: url)
            documents.insert(newDocument, at: 0)
            isLoading = false
        } catch {
            errorMessage = "Error saving PDF: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func createPDFFromPhotos(_ images: [UIImage], fileName: String) {
        guard !images.isEmpty else {
            errorMessage = "You must select at least one photo to create a PDF."
            return
        }
        
        isCreatingPDF = true
        errorMessage = nil
        
        let finalFileName = fileName.isEmpty ? "PDF_\(Date().formatted(date: .abbreviated, time: .shortened))" : fileName
        
        DispatchQueue.global().async {
//            guard let self = self else { return }
            
            if let pdfURL = PDFCreator.createPDF(from: images, fileName: finalFileName) {
                DispatchQueue.main.async {
                    self.addDocument(from: pdfURL)
                    
                    // Временный файл удаляем
                    try? FileManager.default.removeItem(at: pdfURL)
                    
                    self.isCreatingPDF = false
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to create PDF from photos"
                    self.isCreatingPDF = false
                }
            }
        }
    }
    
    func createPDFFromImageURLs(_ urls: [URL], fileName: String) async {
        guard !urls.isEmpty else {
            errorMessage = "No image files selected"
            return
        }
        
        isCreatingPDF = true
        errorMessage = nil
        
        let finalFileName = fileName.isEmpty ? "PDF_\(Date().formatted(date: .abbreviated, time: .shortened))" : fileName
        
        if let pdfURL = await PDFCreator.createPDFFromURLs(urls, fileName: finalFileName) {
            self.addDocument(from: pdfURL, isSecurityScoped: false)
            
            // Очищаем временный файл
            try? FileManager.default.removeItem(at: pdfURL)
            
            self.isCreatingPDF = false
        } else {
            self.errorMessage = "Failed to create PDF from image files"
            self.isCreatingPDF = false
        }
    }
    
    func deleteDocument(_ document: DocumentModel) {
        errorMessage = nil
        
        do {
            try repository.deleteDocument(document)
            documents.removeAll { $0.id == document.id }
        } catch {
            errorMessage = "Failed to delete document: \(error.localizedDescription)"
        }
    }
    
    func deleteDocuments(at offsets: IndexSet) {
        offsets.map { documents[$0] }.forEach { deleteDocument($0) }
    }
    
    var totalDocumentCount: Int {
        repository.getDocumentCount()
    }
}
