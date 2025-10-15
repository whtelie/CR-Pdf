//
//  FileManagerService.swift
//  CR Pdf
//
//  Created by Ivan Mareev on 15.10.2025.
//


import Foundation

class FileManagerService {
    static let shared = FileManagerService()
    private let fileManager: FileManager
    
    private init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    
    func getDocumentsDirectory() -> URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func createDirectoryIfNeeded(at url: URL) throws {
        let directoryURL = url.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: directoryURL.path) {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        }
    }
    
    func fileExists(at url: URL) -> Bool {
        fileManager.fileExists(atPath: url.path)
    }
    
    func removeFile(at url: URL) throws {
        if fileExists(at: url) {
            try fileManager.removeItem(at: url)
        }
    }
    
    func getFileSize(at url: URL) -> Int64? {
        do {
            let attributes = try fileManager.attributesOfItem(atPath: url.path)
            return attributes[.size] as? Int64
        } catch {
            return nil
        }
    }
}