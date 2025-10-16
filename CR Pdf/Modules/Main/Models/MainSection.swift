//
//  MainSection.swift
//  CR Pdf
//
//  Created by Ivan Mareev on 16.10.2025.
//


import Foundation

struct MainSection: Identifiable {
    let id = UUID()
    let title: String
    let systemImage: String
    let documents: [DocumentModel]
}