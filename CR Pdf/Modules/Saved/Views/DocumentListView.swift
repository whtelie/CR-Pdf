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
        VStack {
            if viewModel.documents.isEmpty {
                EmptyStateView()
            } else {
                List {
                    ForEach(viewModel.documents) { document in
                        if viewModel.isSelectionMode {
                            HStack(spacing: 12) {
                                Button {
                                    viewModel.toggleSelection(for: document)
                                } label: {
                                    Image(systemName: viewModel.selectedDocuments.contains(document.id) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(.blue)
                                        .imageScale(.large)
                                }
                                .buttonStyle(.plain)

                                DocumentRowView(
                                    document: document,
                                    isSelected: viewModel.selectedDocuments.contains(document.id),
                                    isSelectionMode: viewModel.isSelectionMode
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    viewModel.toggleSelection(for: document)
                                }

                                Spacer()
                            }
                            .padding(.vertical, 4)
                            .contextMenu { selectionContextMenu(for: document) }
                        } else {
                            ZStack {
                                DocumentRowView(
                                    document: document,
                                    isSelected: viewModel.selectedDocuments.contains(document.id),
                                    isSelectionMode: viewModel.isSelectionMode,
                                    onLikeTapped: { viewModel.toggleLike(for: document) }
                                )
                                .contentShape(Rectangle())
                                NavigationLink(
                                    destination: PDFViewer(document: document, repository: repository) {
                                        viewModel.loadDocuments()
                                    }
                                ) {
                                    EmptyView()
                                }
                                .opacity(0)
                            }
                            .buttonStyle(.plain)
                            .padding(.vertical, 4)
                            .contextMenu { normalContextMenu(for: document) }
                        }
                    }
                    .onDelete(perform: viewModel.deleteDocuments)
                }
                .listRowSeparator(.hidden)
                .listStyle(.plain)
            }
        }
        .sheet(item: $viewModel.selectedDocumentForEditing) { document in
            PDFEditorModule.makeView(document: document, repository: repository) {
                viewModel.loadDocuments()
                viewModel.selectedDocumentForEditing = nil
            }
        }
        .sheet(isPresented: $viewModel.isShareSheetPresented) {
            if let url = viewModel.shareURL {
                ActivityView(activityItems: [url])
            }
        }
    }

    // MARK: - Context Menus Helpers
    @ViewBuilder
    private func normalContextMenu(for document: DocumentModel) -> some View {
        Button {
            viewModel.isSelectionMode = true
            viewModel.toggleSelection(for: document)
        } label: {
            Label("Select", systemImage: "checkmark.circle")
        }
        Divider()
        Button { viewModel.sharePDF(document) } label: { Label("Share", systemImage: "square.and.arrow.up") }
        Button { viewModel.selectedDocumentForEditing = document } label: { Label("Edit", systemImage: "pencil.line") }
        Button(role: .destructive) { viewModel.deleteDocument(document) } label: { Label("Delete", systemImage: "trash") }
    }

    @ViewBuilder
    private func selectionContextMenu(for document: DocumentModel) -> some View {
        Button {
            viewModel.toggleSelection(for: document)
        } label: {
            Label(viewModel.selectedDocuments.contains(document.id) ? "Deselect" : "Select",
                  systemImage: viewModel.selectedDocuments.contains(document.id) ? "checkmark.circle.fill" : "circle")
        }
    }
}
