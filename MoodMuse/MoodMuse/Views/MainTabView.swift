// MainTabView.swift
// MoodMuse

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                MoodInputView()
                    .tag(0)
                FavoritesView()
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            if appState.playingTrack != nil {
                VStack(spacing: 0) {
                    PlayerBarView()
                    customTabBar
                }
            } else {
                customTabBar
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private var customTabBar: some View {
        HStack(spacing: 0) {
            tabItem(icon: "wand.and.stars", label: "Discover",   tag: 0)
            tabItem(icon: "heart.fill",     label: "Favourites", tag: 1)
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 28)
        .background(.ultraThinMaterial)
        .overlay(Rectangle().frame(height: 0.5).foregroundColor(.white.opacity(0.12)), alignment: .top)
    }

    @ViewBuilder
    private func tabItem(icon: String, label: String, tag: Int) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) { selectedTab = tag }
        } label: {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: selectedTab == tag ? .semibold : .regular))
                    .symbolEffect(.bounce, value: selectedTab == tag)
                Text(label)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
            }
            .foregroundColor(selectedTab == tag ? Color(hue: 0.78, saturation: 0.6, brightness: 1.0) : .white.opacity(0.4))
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    MainTabView().environmentObject(AppState())
}
