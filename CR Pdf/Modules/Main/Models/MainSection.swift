//
//  MainSection.swift
//  CR Pdf
//
//  Created by Ivan Mareev on 16.10.2025.
//


import Foundation

public struct MainSection: Identifiable {
    public let id = UUID()
    public let title: String
    public let systemImage: String
    public let documents: [DocumentModel]
}
