//
//  EmptyStateView.swift
//  CR Pdf
//
//  Created by Ivan Mareev on 15.10.2025.
//


import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("There are no documents now")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Tap the + button to create your first PDF document")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
