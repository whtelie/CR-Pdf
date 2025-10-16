//
//  PDFEditorView.swift
//  CR Pdf
//
//  Created by Ivan Mareev on 16.10.2025.
//


import SwiftUI

struct PDFEditorView: View {
    @StateObject var viewModel: PDFEditorViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isProcessing {
                    ProgressView("Processing...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    editorContentView
                }
            }
            .navigationTitle("Edit PDF")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveChanges() }
                        .disabled(viewModel.editedPDFData == nil)
                }
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }
    
    private var editorContentView: some View {
        ScrollView {
            VStack(spacing: 16) {
//                Text("PDF Editor")
//                    .font(.title)
//                    .padding()
                
                LazyVStack(spacing: 12) {
                    ForEach(0..<viewModel.pageCount, id: \.self) { index in
                        HStack {
                            if let thumbnail = viewModel.getPageThumbnail(for: index, size: CGSize(width: 100, height: 150)) {
                                Image(uiImage: thumbnail)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 150)
                                    .cornerRadius(6)
                                    .shadow(radius: 2)
                            }
                            
                            Text("Page \(index + 1)")
                                .font(.headline)
                                .padding(.leading, 8)
                            
                            Spacer()
                            
                            Button(role: .none) {
                                viewModel.rotatePage(at: index)
                            } label: {
                                Image(systemName: "arrow.trianglehead.clockwise")
                            }
                            .padding(.horizontal, 6)
                            Button(role: .destructive) {
                                viewModel.removePage(at: index + 1)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .disabled(viewModel.pageCount <= 1)
                        }
                        .padding(.horizontal)
                    }
                }
                
                Button("Rotate All Pages") {
                    viewModel.rotateAllPages()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top)
            }
            .padding(.top)
        }
    }
    
    private func saveChanges() {
        do {
            try viewModel.saveChanges()
            viewModel.onSave?()
            dismiss()
        } catch {
            print("Failed to save changes: \(error)")
        }
    }
}
