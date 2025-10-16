//
//  DocumentListView.swift
//  CR Pdf
//
//  Created by Ivan Mareev on 15.10.2025.
//


import SwiftUI

struct DocumentListView: View {
    @ObservedObject var viewModel: SavedViewModel
    
    var body: some View {
        Group {
            if viewModel.documents.isEmpty {
                EmptyStateView()
            } else {
                List {
                    ForEach(viewModel.documents) { document in
                        NavigationLink(destination: PDFViewer(document: document)) {
                            DocumentRowView(document: document)
                        }
                        //                        DocumentRowView(document: document)
                        .swipeActions {
                            Button(role: .destructive) {
                                viewModel.deleteDocument(document)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .onDelete(perform: viewModel.deleteDocuments)
                }
                .listStyle(.plain)
            }
        }
    }
}
