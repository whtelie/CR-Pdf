//
//  CR_PdfApp.swift
//  CR Pdf
//
//  Created by Ivan Mareev on 15.10.2025.
//

import SwiftUI
import CoreData

@main
struct CR_PdfApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
