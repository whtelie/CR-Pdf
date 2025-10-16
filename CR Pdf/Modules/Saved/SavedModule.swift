//
//  SavedModule.swift
//  CR Pdf
//
//  Created by Ivan Mareev on 15.10.2025.
//

import SwiftUI
import CoreData

public enum SavedModule {
    public static func makeView(context: NSManagedObjectContext) -> some View {
        let repository = CoreDataDocumentRepository(context: context)
        let viewModel = SavedViewModel(repository: repository)
        return SavedView(viewModel: viewModel)
    }
}
