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
                Button(action: onCancel) {
                    Text("Cancel")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
                Button(action: onSave) {
                    Text("Save")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .padding(.top)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        
    }
}
