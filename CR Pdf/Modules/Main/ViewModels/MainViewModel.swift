//
//  MainViewModel.swift
//  CR Pdf
//
//  Created by Ivan Mareev on 15.10.2025.
//

import Foundation
import Combine

final class MainViewModel: ObservableObject {
    @Published var sections: [MainSection] = []
    @Published var documents: [DocumentModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var isSelectionMode = false
    @Published var selectedDocuments: Set<UUID> = []
    @Published var selectedDocumentForEditing: DocumentModel?
    @Published var isShareSheetPresented = false
    @Published var shareURL: URL?
    
    let repository: DocumentRepository
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: DocumentRepository) {
        self.repository = repository
        loadSections()
    }
    
    func loadSections() {
        isLoading = true
        errorMessage = nil
        
        do {
            let allDocuments = try repository.fetchAllDocuments()
            documents = allDocuments
            updateSections(with: allDocuments)
            isLoading = false
        } catch {
            errorMessage = "Failed to load documents: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    private func updateSections(with documents: [DocumentModel]) {
        let likedDocuments = documents.filter { $0.isLiked }
        let recentDocuments = documents.filter { $0.isRecent }
        
        sections = [
            MainSection(
                title: "Favorites",
                systemImage: "heart.fill",
                documents: likedDocuments
            ),
            MainSection(
                title: "Recently Added",
                systemImage: "clock.fill",
                documents: recentDocuments
            )
        ]
    }
    
    // MARK: - Selection Management (как в SavedViewModel)
    
    func toggleSelection(for document: DocumentModel) {
        if selectedDocuments.contains(document.id) {
            selectedDocuments.remove(document.id)
        } else {
            selectedDocuments.insert(document.id)
        }
    }
    
    func deleteDocument(_ document: DocumentModel) {
        errorMessage = nil
        do {
            try repository.deleteDocument(document)
            loadSections() // Обновляем секции после удаления
        } catch {
            errorMessage = "Failed to delete document: \(error.localizedDescription)"
        }
    }
    
    func sharePDF(_ document: DocumentModel) {
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempFileURL = tempDirectory.appendingPathComponent("\(document.name).pdf")
        
        do {
            try document.pdfData.write(to: tempFileURL)
            shareURL = tempFileURL
            isShareSheetPresented = true
        } catch {
            errorMessage = "Failed to prepare PDF for sharing"
        }
    }
    
    func startEditing(_ document: DocumentModel) {
        selectedDocumentForEditing = document
    }
    
    func refreshData() {
        loadSections()
    }
    
    func cancelSelection() {
        selectedDocuments.removeAll()
        isSelectionMode = false
    }
    
    func mergeSelectedDocuments(with name: String? = nil) {
        let docsToMerge = documents.filter { selectedDocuments.contains($0.id) }
        guard docsToMerge.count >= 2 else {
            errorMessage = "Please select at least 2 documents to merge"
            return
        }

        Task { [weak self] in
            guard let self = self else { return }
            do {
                let mergedData = try PDFEditorService().mergePDFs(docsToMerge.map(\.pdfData))
                let mergedName = name ?? "Merged \(DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short))"
                let newDocument = try repository.saveDocument(from: mergedData, name: mergedName)
                
                await MainActor.run {
                    self.documents.insert(newDocument, at: 0)
                    self.cancelSelection()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to merge PDFs: \(error.localizedDescription)"
                }
            }
        }
        isSelectionMode = false
    }
}
