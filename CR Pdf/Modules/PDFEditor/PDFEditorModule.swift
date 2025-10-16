//
//  PDFEditorModule.swift
//  CR Pdf
//
//  Created by Ivan Mareev on 16.10.2025.
//


import SwiftUI
import CoreData

public enum PDFEditorModule {
    public static func makeView(document: DocumentModel, repository: DocumentRepository, onSave: @escaping () -> Void) -> some View {
        let pdfEditorService = PDFEditorService()
        let viewModel = PDFEditorViewModel(
            document: document,
            documentRepository: repository,
            pdfEditor: pdfEditorService
        )
        viewModel.onSave = onSave
        return PDFEditorView(viewModel: viewModel)
    }
}
