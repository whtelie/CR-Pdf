//
//  SavedViewModel.swift
//  CR Pdf
//
//  Created by Ivan Mareev on 15.10.2025.
//

import Foundation
import Combine

final class SavedViewModel: ObservableObject {
    @Published var documents: [DocumentModel] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    
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
    
    func addDocument(from url: URL) {
        guard url.startAccessingSecurityScopedResource() else {
            errorMessage = "Cannot access the selected file"
            return
        }
        
        defer { url.stopAccessingSecurityScopedResource() }
        
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
