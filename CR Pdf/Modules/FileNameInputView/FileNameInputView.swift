//
//  FileNameInputView.swift
//  CR Pdf
//
//  Created by Ivan Mareev on 16.10.2025.
//

import SwiftUI

struct FileNameInputBottomSheet: View {
    @Binding var fileName: String
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Enter file name or use default")
                .font(.headline)
            TextField("File name", text: $fileName)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            HStack {
                Button("Cancel", action: onCancel)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(12)
                Button("Save", action: onSave)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .padding(.top)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        
    }
}
