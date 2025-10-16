//
//  SavedView.swift
//  CR Pdf
//
//  Created by Ivan Mareev on 15.10.2025.
//

import SwiftUI
import UniformTypeIdentifiers
import Combine

struct SavedView: View {
    @StateObject private var viewModel: SavedViewModel
    @StateObject private var imagePickerService = ImagePickerService()

    @State private var isImporterPresented = false
    @State private var isPhotoPickerPresented = false
    @State private var isFilePickerPresented = false
    
    @State private var isFileNameSheetPresented = false
    @State private var newFileName: String = ""
    @State private var pendingImageURLs: [URL] = []
    @State private var pendingPhotos: [UIImage] = []
    
    @State private var keyboardHeight: CGFloat = 0

    
    init(viewModel: SavedViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    if viewModel.isLoading {
                        ProgressView("Loading documents...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        DocumentListView(viewModel: viewModel, repository: viewModel.repository)
                    }
                }
                VStack {
                    Spacer()
                    if isFileNameSheetPresented {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .onTapGesture {
                                isFileNameSheetPresented = false
                            }
                        FileNameInputBottomSheet(fileName: $newFileName) {
                            isFileNameSheetPresented = false
                            Task {
                                if !pendingImageURLs.isEmpty {
                                    await viewModel.createPDFFromImageURLs(pendingImageURLs, fileName: newFileName)
                                    pendingImageURLs = []
                                } else if !pendingPhotos.isEmpty {
                                    viewModel.createPDFFromPhotos(pendingPhotos, fileName: newFileName)
                                    pendingPhotos = []
                                }
                            }
                        } onCancel: {
                            isFileNameSheetPresented = false
                            pendingImageURLs = []
                            pendingPhotos = []
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.spring(), value: isFileNameSheetPresented)
                        .ignoresSafeArea()
                    }
                }
            }
            .onReceive(KeyboardHeightHelper.keyboardHeight) { height in
                keyboardHeight = height
            }
            .navigationTitle("Saved PDF documents")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { isPhotoPickerPresented = true }) {
                            Label("Add document from photo", systemImage: "plus")
                        }
                        .disabled(viewModel.isLoading)
                        Button(action: { isFilePickerPresented = true }) {
                            Label("Add document from file", systemImage: "plus")
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
            isPresented: $isFilePickerPresented,
            allowedContentTypes: [.image],
            allowsMultipleSelection: true
        ) { result in
            handleImageFileImport(result)
        }
        .sheet(isPresented: $isPhotoPickerPresented) {
            ImagePickerView(service: imagePickerService) { images in
                handlePhotosSelected(images)
                imagePickerService.reset()
            }
        }
        .onAppear {
            viewModel.loadDocuments()
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
            pendingImageURLs = urls
            newFileName = ""
            isFileNameSheetPresented = true
        case .failure(let error):
            viewModel.errorMessage = "Error selecting images: \(error.localizedDescription)"
        }
    }
    
    private func handlePhotosSelected(_ images: [UIImage]) {
        pendingPhotos = images
        newFileName = ""
        isFileNameSheetPresented = true
    }
}
