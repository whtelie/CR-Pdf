//
//  DocumentError.swift
//  CR Pdf
//
//  Created by Ivan Mareev on 15.10.2025.
//


import Foundation

public enum DocumentError: Error, LocalizedError {
    case documentNotFound
    case fileAccessDenied
    case invalidDocument
    case fileCopyFailed
    case invalidURL
    
    public var errorDescription: String? {
        switch self {
        case .documentNotFound:
            return "Document not found"
        case .fileAccessDenied:
            return "Access to file was denied"
        case .invalidDocument:
            return "Invalid document data"
        case .fileCopyFailed:
            return "Failed to copy file"
        case .invalidURL:
            return "Invalid file URL"
        }
    }
}
