// RecommendationsView.swift
// MoodMuse

import SwiftUI

struct RecommendationsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    private var mood: Mood { appState.currentMood ?? .calm }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.04, blue: 0.14),
                    mood.color.opacity(0.12),
                    Color(red: 0.04, green: 0.04, blue: 0.10)
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            if appState.isLoading {
                loadingView
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 10) {
                        moodHeader
                            .padding(.bottom, 8)
                        ForEach(appState.tracks) { track in
                            TrackRowView(track: track)
                        }
                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 8)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(.white.opacity(0.8))
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task { await appState.fetchRecommendations(for: mood) }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "shuffle")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Shuffle")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(mood.color)
                }
            }
        }
        .toolbarBackground(.clear, for: .navigationBar)
    }

    private var moodHeader: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(mood.color.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .blur(radius: 20)
                Text(mood.emoji)
                    .font(.system(size: 52))
            }
            Text(mood.displayName)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(colors: [.white, mood.color.opacity(0.9)],
                                   startPoint: .leading, endPoint: .trailing)
                )
            Text("\(appState.tracks.count) tracks for your vibe")
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(.white.opacity(0.45))
        }
        .padding(.vertical, 24)
    }

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(mood.color)
                .scaleEffect(1.5)
            Text("Curating your \(mood.displayName.lowercased()) playlist…")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

#Preview {
    NavigationStack {
        RecommendationsView()
            .environmentObject(AppState())
    }
}
