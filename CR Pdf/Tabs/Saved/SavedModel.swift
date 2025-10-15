//
//  SavedModel.swift
//  CR Pdf
//
//  Created by Ivan Mareev on 15.10.2025.
//

import Foundation
import CoreData
import UniformTypeIdentifiers

@objc(SavedModel)
public class SavedModel: NSManagedObject {}

extension SavedModel {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedModel> {
        return NSFetchRequest<SavedModel>(entityName: "Document")
    }
}

