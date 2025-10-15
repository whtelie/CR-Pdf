//
//  Persistence.swift
//  CR Pdf
//
//  Created by Ivan Mareev on 15.10.2025.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

        let container: NSPersistentContainer

        init(inMemory: Bool = false) {
            container = NSPersistentContainer(name: "CR_Pdf")
            
            if inMemory {
                container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
            }

            container.loadPersistentStores { description, error in
                if let error = error {
                    fatalError("Error: \(error.localizedDescription)")
                }
            }
        }
}
