//
//  ContentView.swift
//  CR Pdf
//
//  Created by Ivan Mareev on 15.10.2025.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        TabView {
            Text("Home")
                .tabItem {
                    Label("Home", systemImage: "home")
                }
            SavedModule.makeView(context: viewContext)
                .tabItem {
                    Label("Documents", systemImage: "doc.fill")
                }
        }
    }
}
