// PlayerBarView.swift
// MoodMuse

import SwiftUI

struct PlayerBarView: View {
    @EnvironmentObject var appState: AppState

    private var track: Track? { appState.playingTrack }

    var body: some View {
        guard let track else { return AnyView(EmptyView()) }
        return AnyView(content(for: track))
    }

    @ViewBuilder
    private func content(for track: Track) -> some View {
        HStack(spacing: 14) {
            AsyncImage(url: track.albumArtURL) { phase in
                if case .success(let img) = phase {
                    img.resizable().aspectRatio(contentMode: .fill)
                } else {
                    Color.white.opacity(0.1)
                }
            }
            .frame(width: 44, height: 44)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(track.name)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text(track.artistNames)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.white.opacity(0.55))
                    .lineLimit(1)
            }

            Spacer()

            HStack(spacing: 18) {
                Button { appState.togglePlayPause() } label: {
                    Image(systemName: appState.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                Button { appState.stopPlayback() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .background(
            LinearGradient(
                colors: [Color(hue: 0.78, saturation: 0.3, brightness: 0.25),
                         Color(red: 0.06, green: 0.06, blue: 0.14)],
                startPoint: .leading, endPoint: .trailing
            )
        )
        .overlay(Rectangle().frame(height: 0.5).foregroundColor(.white.opacity(0.12)), alignment: .top)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(response: 0.4), value: appState.playingTrack?.id)
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.height > 60 { appState.stopPlayback() }
                }
        )
    }
}

#Preview {
    PlayerBarView().environmentObject(AppState())
}
