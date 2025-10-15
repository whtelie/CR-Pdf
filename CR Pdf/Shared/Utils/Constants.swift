//
//  Constants.swift
//  CR Pdf
//
//  Created by Ivan Mareev on 15.10.2025.
//


import Foundation

enum Constants {
    static let pdfsDirectoryName = "PDFs"
    static let recentDocumentDays = 7
    
    enum UserDefaultsKeys {
        static let firstLaunch = "isFirstLaunch"
        static let lastSyncDate = "lastSyncDate"
    }
}