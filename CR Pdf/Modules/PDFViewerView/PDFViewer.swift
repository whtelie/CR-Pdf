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
        VStack(alignment: .center) {
            Text(document.name)
                .font(.title)
            PDFKitView(data: document.pdfData)
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
