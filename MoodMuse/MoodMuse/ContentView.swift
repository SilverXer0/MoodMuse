// ContentView.swift
// MoodMuse
//
// Created by Sharan Krishna on 5/20/25.

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if appState.auth.isAuthenticated {
                MainTabView()
            } else {
                SpotifyLoginView()
            }
        }
        .animation(.easeInOut(duration: 0.4), value: appState.auth.isAuthenticated)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
