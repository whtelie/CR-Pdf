//
//  PDFViewer.swift
//  CR Pdf
//
//  Created by Ivan Mareev on 16.10.2025.
//


import SwiftUI
import PDFKit

struct PDFViewer: View {
    let document: DocumentModel
    let repository: DocumentRepository
    
    var onUpdate: (() -> Void)? = nil
    
    @Environment(\.dismiss) private var dismiss

    @State private var isShowingShareSheet = false
    @State private var isShowingEditor = false
    @State private var tempFileURL: URL?

    var body: some View {
        PDFKitView(data: document.pdfData)
            .edgesIgnoringSafeArea(.all)
            .navigationTitle(document.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    shareButton
                    editButton
                }
            }
            .sheet(isPresented: $isShowingShareSheet) {
                if let url = tempFileURL {
                    ActivityView(activityItems: [url])
                }
            }
            .sheet(isPresented: $isShowingEditor) {
                PDFEditorModule.makeView(document: document, repository: repository) {
                    onUpdate?()
                    isShowingEditor = false
                    dismissToRoot()
                }
            }
    }

    // MARK: - Toolbar Buttons

    private var shareButton: some View {
        Button {
            prepareTempFileAndShare()
        } label: {
            Label("Share", systemImage: "square.and.arrow.up")
        }
        .accessibilityLabel("Share PDF")
    }

    private var editButton: some View {
        Button {
            isShowingEditor = true
        } label: {
            Label("Edit", systemImage: "pencil.circle")
        }
        .accessibilityLabel("Edit PDF")
    }
    
    private func dismissToRoot() {
        DispatchQueue.main.async {
            dismiss()
        }
    }

    // MARK: - File Handling

    private func prepareTempFileAndShare() {
        do {
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString + ".pdf")
            try document.pdfData.write(to: tempURL)
            tempFileURL = tempURL
            isShowingShareSheet = true
        } catch {
            print(error)
        }
    }
}


struct PDFKitView: UIViewRepresentable {
    let data: Data

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.backgroundColor = .clear
        pdfView.document = PDFDocument(data: data)
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}
