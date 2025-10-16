//
//  DocumentRowView.swift
//  CR Pdf
//
//  Created by Ivan Mareev on 15.10.2025.
//


import SwiftUI

struct DocumentRowView: View {
    let document: DocumentModel
    let isSelected: Bool
    let isSelectionMode: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Group {
                    if let image = document.thumbnail {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 70)
                            .cornerRadius(8)
                            .shadow(radius: 2)
                    } else {
                        Image(systemName: "doc.fill")
                            .foregroundColor(.red)
                            .font(.title3)
                    }
                }
                .padding(.trailing, 5)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(document.name)
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    HStack {
                        if let pageCount = document.pageCount {
                            Text("\(pageCount) pages")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(document.formattedDate)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(document.fileSize)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
        }
        .padding(.vertical, 4)
    }
}
