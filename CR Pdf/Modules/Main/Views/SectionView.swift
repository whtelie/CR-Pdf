//
//  SectionView.swift
//  CR Pdf
//
//  Created by Ivan Mareev on 16.10.2025.
//

//
//  SectionView.swift
//  CR Pdf
//
//  Created by Ivan Mareev on 16.10.2025.
//

import SwiftUI

struct SectionView: View {
    let section: MainSection
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: section.systemImage)
                    .foregroundColor(.blue)
                    .font(.title3)
                
                Text(section.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(section.documents.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            
            LazyVStack(spacing: 8) {
                ForEach(section.documents) { document in
                    let row = DocumentRowView(
                        document: document,
                        isSelected: viewModel.selectedDocuments.contains(document.id),
                        isSelectionMode: viewModel.isSelectionMode,
                        onLikeTapped: {
                            viewModel.toggleLike(for: document)
                            viewModel.refreshData()
                        }
                    )
                    .contentShape(Rectangle())
                    
                    if viewModel.isSelectionMode {
                        HStack(spacing: 12) {
                            Button {
                                viewModel.toggleSelection(for: document)
                            } label: {
                                Image(systemName: viewModel.selectedDocuments.contains(document.id)
                                      ? "checkmark.circle.fill"
                                      : "circle")
                                    .font(.system(size: 20))
                                    .foregroundColor(viewModel.selectedDocuments.contains(document.id)
                                                     ? .blue
                                                     : .secondary)
                            }
                            .buttonStyle(.plain)
                            
                            row
                                .onTapGesture {
                                    viewModel.toggleSelection(for: document)
                                }
                            
                            Spacer(minLength: 0)
                        }
                        .padding(.vertical, 6)
                        .contextMenu {
                            contextMenu(for: document)
                        }
                        
                    } else {
                        NavigationLink(
                            destination: PDFViewer(
                                document: document,
                                repository: viewModel.repository
                            ) {
                                viewModel.loadSections()
                            }
                        ) {
                            row
                        }
                        .buttonStyle(.plain)
                        .padding(.vertical, 6)
                        .contextMenu {
                            contextMenu(for: document)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func contextMenu(for document: DocumentModel) -> some View {
        if viewModel.isSelectionMode {
            Button {
                viewModel.toggleSelection(for: document)
            } label: {
                Label(
                    viewModel.selectedDocuments.contains(document.id) ? "Deselect" : "Select",
                    systemImage: viewModel.selectedDocuments.contains(document.id) ? "checkmark.circle.fill" : "circle"
                )
            }
        } else {
            Button {
                withAnimation {
                    viewModel.isSelectionMode = true
                    viewModel.toggleSelection(for: document)
                }
            } label: {
                Label("Select", systemImage: "checkmark.circle")
            }
            
            Divider()
            
            Button {
                viewModel.sharePDF(document)
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            
            Button {
                viewModel.startEditing(document)
            } label: {
                Label("Edit", systemImage: "pencil.line")
            }
            
            Button(role: .destructive) {
                viewModel.deleteDocument(document)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
