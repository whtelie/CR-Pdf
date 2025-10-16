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

    var body: some View {
        PDFKitView(data: document.pdfData)
            .navigationTitle(document.name)
    }
}

struct PDFKitView: UIViewRepresentable {
    let data: Data

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.document = PDFDocument(data: data)
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}
