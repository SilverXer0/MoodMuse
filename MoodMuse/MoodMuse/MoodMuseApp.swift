// MoodMuseApp.swift
// MoodMuse
//
// Created by Sharan Krishna on 5/20/25.

import SwiftUI

@main
struct MoodMuseApp: App {

    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onOpenURL { url in
                    Task { await appState.auth.handleCallback(url: url) }
                }
        }
    }
}
