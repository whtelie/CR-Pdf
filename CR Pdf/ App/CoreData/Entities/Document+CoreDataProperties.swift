//
//  Document+CoreDataProperties.swift
//  CR Pdf
//
//  Created by Ivan Mareev on 15.10.2025.
//

import Foundation
import CoreData

extension Document {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Document> {
        return NSFetchRequest<Document>(entityName: "Document")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var creationDate: Date?
    @NSManaged public var fileURL: URL?
    @NSManaged public var fileSize: String?
    @NSManaged public var pageCount: NSNumber?

}
