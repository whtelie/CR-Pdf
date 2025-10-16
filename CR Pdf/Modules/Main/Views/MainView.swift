//
//  MainView.swift
//  CR Pdf
//
//  Created by Ivan Mareev on 15.10.2025.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel: MainViewModel
    @Environment(\.managedObjectContext) private var viewContext
    
    init(viewModel: MainViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    VStack {
                        if viewModel.isLoading {
                            ProgressView("Loading...")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            mainContent
                        }
                    }
                    .navigationTitle("Main")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                viewModel.refreshData()
                            } label: {
                                Image(systemName: "arrow.clockwise")
                            }
                        }
                    }
                    if viewModel.isSelectionMode {
                        VStack(spacing: 12) {
                            Divider()
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Selection Mode")
                                        .font(.headline)
                                    Text("\(viewModel.selectedDocuments.count) documents selected")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Button("Cancel") {
                                    viewModel.cancelSelection()
                                }
                                .foregroundColor(.red)
                                
                                Button {
                                    viewModel.mergeSelectedDocuments()
                                    viewModel.loadSections()
                                } label: {
                                    HStack {
                                        Image(systemName: "doc.on.doc")
                                        Text("Merge")
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        viewModel.selectedDocuments.count >= 2
                                        ? Color.blue
                                        : Color.gray
                                    )
                                    .cornerRadius(8)
                                }
                                .disabled(viewModel.selectedDocuments.count < 2)
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                        }
                        .padding(.bottom, 16)
                        .background(Color(.systemBackground))
                        .transition(.move(edge: .bottom))
                    }
                }
            }
            .sheet(item: $viewModel.selectedDocumentForEditing) { document in
                PDFEditorModule.makeView(document: document, repository: viewModel.repository) {
                    viewModel.loadSections()
                    viewModel.selectedDocumentForEditing = nil
                }
            }
            .sheet(isPresented: $viewModel.isShareSheetPresented) {
                if let url = viewModel.shareURL {
                    ActivityView(activityItems: [url])
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
            .onAppear {
                viewModel.loadSections()
            }
        }
        
        
    }
    private var mainContent: some View {
        if viewModel.sections.count > 1 && viewModel.sections[1].documents.isEmpty {
            AnyView(EmptyStateView())
        } else {
            AnyView(ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    ForEach(viewModel.sections) { section in
                        if !section.documents.isEmpty {
                            SectionView(
                                section: section,
                                viewModel: viewModel
                            )
                        }
                        
                    }
                }
                .padding()
            })
        }
    }
}
