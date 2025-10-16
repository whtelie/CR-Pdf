//
//  MainModule.swift
//  CR Pdf
//
//  Created by Ivan Mareev on 15.10.2025.
//

import SwiftUI
import CoreData

public enum MainModule {
    public static func makeView(context: NSManagedObjectContext) -> some View {
        let repository = CoreDataDocumentRepository(context: context)
        let viewModel = MainViewModel(repository: repository)
        return MainView(viewModel: viewModel)
    }
}
