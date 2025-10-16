//
//  SavedView.swift
//  CR Pdf
//
//  Created by Ivan Mareev on 15.10.2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct SavedView: View {
    @StateObject private var viewModel: SavedViewModel
    @StateObject private var imagePickerService = ImagePickerService()

    @State private var isImporterPresented = false
    @State private var isShowPhotoPicker = false
    
    init(viewModel: SavedViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading documents...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    DocumentListView(viewModel: viewModel)
                }
            }
            .navigationTitle("Saved PDF documents")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { isShowPhotoPicker = true }) {
                            Label("Add photo", systemImage: "plus")
                        }
                        Button(action: { isImporterPresented = true }) {
                            Label("Add PDF", systemImage: "plus")
                        }
                        .disabled(viewModel.isLoading)
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
        .fileImporter(
            isPresented: $isImporterPresented,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result)
        }
        .sheet(isPresented: $isShowPhotoPicker) {
            ImagePickerView(service: imagePickerService)
        }
        .onAppear {
            viewModel.loadDocuments()
        }
        .onReceive(imagePickerService.$selectedImages) { newImages in
            guard !newImages.isEmpty else { return }
            viewModel.createPDFFromPhotos(newImages, fileName: "")
            imagePickerService.reset()
        }
    }
    
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                viewModel.addDocument(from: url)
            }
        case .failure(let error):
            viewModel.errorMessage = "Error selecting PDF: \(error.localizedDescription)"
        }
    }
}
