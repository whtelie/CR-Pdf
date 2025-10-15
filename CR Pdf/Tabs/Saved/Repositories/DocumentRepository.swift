//
//  DocumentRepository.swift
//  CR Pdf
//
//  Created by Ivan Mareev on 15.10.2025.
//


import Foundation
import CoreData

protocol DocumentRepository {
    func fetchAllDocuments() throws -> [DocumentModel]
    func saveDocument(from url: URL) throws -> DocumentModel
    func deleteDocument(_ document: DocumentModel) throws
    func getDocumentCount() -> Int
}

class CoreDataDocumentRepository: DocumentRepository {
    private let context: NSManagedObjectContext
    private let fileManager: FileManager
    
    init(context: NSManagedObjectContext, fileManager: FileManager = .default) {
        self.context = context
        self.fileManager = fileManager
    }
    
    func fetchAllDocuments() throws -> [DocumentModel] {
        let request: NSFetchRequest<Document> = Document.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Document.creationDate, ascending: false)]
        
        let coreDataDocuments = try context.fetch(request)
        return try coreDataDocuments.map { try $0.toDomainModel() }
    }
    
    func saveDocument(from url: URL) throws -> DocumentModel {
        let document = Document(context: context)
        document.id = UUID()
        document.creationDate = Date()
        document.name = url.deletingPathExtension().lastPathComponent
        
        try document.copyFile(from: url)
        try context.save()
        
        return try document.toDomainModel()
    }
    
    func deleteDocument(_ document: DocumentModel) throws {
        let request: NSFetchRequest<Document> = Document.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", document.id as CVarArg)
        
        guard let coreDataDocument = try context.fetch(request).first else {
            throw DocumentError.documentNotFound
        }
        
        coreDataDocument.deleteFile()
        context.delete(coreDataDocument)
        try context.save()
    }
    
    func getDocumentCount() -> Int {
        let request: NSFetchRequest<Document> = Document.fetchRequest()
        return (try? context.count(for: request)) ?? 0
    }
}