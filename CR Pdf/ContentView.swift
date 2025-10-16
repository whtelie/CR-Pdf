//
//  ContentView.swift
//  CR Pdf
//
//  Created by Ivan Mareev on 15.10.2025.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome: Bool = false
    @State private var showWelcome: Bool = false

    var body: some View {
        ZStack {
            TabView {
                MainModule.makeView(context: viewContext)
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                SavedModule.makeView(context: viewContext)
                    .tabItem {
                        Label("Documents", systemImage: "doc.fill")
                    }
            }

            if showWelcome && !hasSeenWelcome {
                welcomeOverlay
            }
        }
        .onAppear {
            showWelcome = !hasSeenWelcome
        }
    }

    private var welcomeOverlay: some View {
        VStack {
            Spacer()
            VStack(spacing: 16) {
                Text("Welcome to CR PDF!")
                    .font(.title)
                    .fontWeight(.semibold)
                Text("You can create, store, and edit PDF documents directly within the app.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 24)
                Button(action: {
                    showWelcome = false
                    hasSeenWelcome = true
                }) {
                    Text("Start")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 24)
                }
            }
            Spacer()
        }
        .background(Color(.systemBackground).opacity(0.95))
        .edgesIgnoringSafeArea(.all)
    }
}


