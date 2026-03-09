// FavoritesView.swift
// MoodMuse

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var appState: AppState

    private let bg = Color(red: 0.05, green: 0.04, blue: 0.14)

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()

            if appState.favorites.isEmpty {
                emptyState
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 10) {
                        VStack(spacing: 4) {
                            Text("Favourites")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text("\(appState.favorites.count) saved tracks")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.white.opacity(0.45))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 16)
                        .padding(.bottom, 12)

                        ForEach(appState.favorites) { track in
                            TrackRowView(track: track)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        withAnimation { appState.toggleFavorite(track) }
                                    } label: {
                                        Label("Remove", systemImage: "heart.slash.fill")
                                    }
                                }
                        }

                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal, 18)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear { appState.favorites = appState.storage.getFavorites() }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color(hue: 0.93, saturation: 0.5, brightness: 0.7).opacity(0.2))
                    .frame(width: 110, height: 110)
                    .blur(radius: 20)
                Image(systemName: "heart.slash")
                    .font(.system(size: 44, weight: .light))
                    .foregroundColor(.white.opacity(0.3))
            }
            Text("No favourites yet")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
            Text("Tap the ♥ on any track to\nsave it here for later")
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(.white.opacity(0.45))
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    FavoritesView().environmentObject(AppState())
}
