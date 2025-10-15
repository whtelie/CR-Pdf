//
//  DocumentModel.swift
//  CR Pdf
//
//  Created by Ivan Mareev on 15.10.2025.
//


import Foundation

struct DocumentModel: Identifiable, Equatable {
    let id: UUID
    let name: String
    let creationDate: Date
    let fileURL: URL
    let fileSize: String
    let pageCount: Int?
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: creationDate)
    }
}
