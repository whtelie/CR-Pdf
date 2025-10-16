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
    @State private var isPhotoPickerPresented = false
    @State private var isFilePickerPresented = false
    
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
                        Button(action: { isPhotoPickerPresented = true }) {
                            Label("Add photo", systemImage: "plus")
                        }
                        Button(action: { isFilePickerPresented = true }) {
                            Label("Add photo from file", systemImage: "plus")
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
        .fileImporter(
                    isPresented: $isFilePickerPresented,
                    allowedContentTypes: [.image],
                    allowsMultipleSelection: true
        ) { result in
            handleImageFileImport(result)
        }
        .sheet(isPresented: $isPhotoPickerPresented) {
            ImagePickerView(service: imagePickerService)
        }
        .onAppear {
            viewModel.loadDocuments()
        }
        .onReceive(imagePickerService.$selectedImages) { newImages in
            guard !newImages.isEmpty else {
                viewModel.errorMessage = "No images were picked."
                return
            }
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
    
    private func handleImageFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            Task {
                await viewModel.createPDFFromImageURLs(urls, fileName: "")
            }
        case .failure(let error):
            viewModel.errorMessage = "Error selecting images: \(error.localizedDescription)"
        }
    }
}
