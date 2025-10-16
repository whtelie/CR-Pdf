//
//  DocumentListView.swift
//  CR Pdf
//
//  Created by Ivan Mareev on 15.10.2025.
//


import SwiftUI

struct DocumentListView: View {
    @ObservedObject var viewModel: SavedViewModel
    let repository: DocumentRepository
    
    
    var body: some View {
        Group {
            if viewModel.documents.isEmpty {
                EmptyStateView()
            } else {
                List {
                    ForEach(viewModel.documents) { document in
                        ZStack {
                            DocumentRowView(document: document)
                                .contextMenu {
                                    Button {
                                        viewModel.sharePDF(document)
                                    } label: {
                                        Label("Share", systemImage: "square.and.arrow.up")
                                    }
                                    Button {
                                        viewModel.selectedDocumentForEditing = document
                                    } label: {
                                        Label("Edit", systemImage: "pencil.line")
                                    }
                                    Button {
                                        viewModel.deleteDocument(document)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            NavigationLink(
                                destination: PDFViewer(
                                    document: document,
                                    repository: repository
                                ) {
                                    viewModel.loadDocuments()
                                }
                            ) {
                                EmptyView()
                            }
                            .opacity(0)

                        }
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
        .sheet(item: $viewModel.selectedDocumentForEditing) { document in
            PDFEditorModule.makeView(document: document, repository: repository) {
                self.viewModel.loadDocuments()
                self.viewModel.selectedDocumentForEditing = nil
            }
        }
        .sheet(isPresented: $viewModel.isShareSheetPresented) {
            if let url = viewModel.shareURL {
                ActivityView(activityItems: [url])
            }
        }
    }
}
