//
//  DocumentRepository.swift
//  CR Pdf
//
//  Created by Ivan Mareev on 15.10.2025.
//


import Foundation
import CoreData
import PDFKit

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
            var documents: [DocumentModel] = []
            for coreDataDocument in coreDataDocuments {
                do {
                    let documentModel = try coreDataDocument.toDomainModel()
                    documents.append(documentModel)
                } catch {
                    print("Error mapping document: \(error)")
                    // Можно здесь удалить битый документ?
                }
            }
            return documents
    }
    
    func saveDocument(from url: URL) throws -> DocumentModel {
        let document = Document(context: context)
        document.id = UUID()
        document.creationDate = Date()
        document.name = url.deletingPathExtension().lastPathComponent
        
        let data = try Data(contentsOf: url)
        document.pdfData = data
        
        document.thumbnailData = generateThumbnail(from: data)
        
        try context.save()
        
        return try document.toDomainModel()
    }
    
    func deleteDocument(_ document: DocumentModel) throws {
        let request: NSFetchRequest<Document> = Document.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", document.id as CVarArg)
        
        guard let coreDataDocument = try context.fetch(request).first else {
            throw DocumentError.documentNotFound
        }
        
//        coreDataDocument.deleteFile()
        context.delete(coreDataDocument)
        try context.save()
    }
    
    func getDocumentCount() -> Int {
        let request: NSFetchRequest<Document> = Document.fetchRequest()
        return (try? context.count(for: request)) ?? 0
    }
}

extension CoreDataDocumentRepository {
    private func generateThumbnail(from pdfData: Data, scale: CGFloat = 0.2) -> Data? {
        guard let pdfDocument = PDFDocument(data: pdfData),
              let page = pdfDocument.page(at: 0) else { return nil }
        
        let pageRect = page.bounds(for: .mediaBox)
        let thumbnailSize = CGSize(width: pageRect.width * scale, height: pageRect.height * scale)
        
        UIGraphicsBeginImageContextWithOptions(thumbnailSize, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(origin: .zero, size: thumbnailSize))
        
        context.translateBy(x: 0, y: thumbnailSize.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        let scaleX = thumbnailSize.width / pageRect.width
        let scaleY = thumbnailSize.height / pageRect.height
        context.saveGState()
        context.scaleBy(x: scaleX, y: scaleY)
        page.draw(with: .mediaBox, to: context)
        context.restoreGState()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image?.jpegData(compressionQuality: 0.8)
    }
}
