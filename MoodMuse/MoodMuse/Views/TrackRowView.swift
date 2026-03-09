// TrackRowView.swift
// MoodMuse

import SwiftUI

struct TrackRowView: View {
    let track: Track
    @EnvironmentObject var appState: AppState
    @State private var isPressed = false

    private var isFav: Bool { appState.isFavorite(track) }
    private var isCurrentlyPlaying: Bool { appState.playingTrack?.id == track.id }

    var body: some View {
        HStack(spacing: 14) {
            AsyncImage(url: track.albumArtURL) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().aspectRatio(contentMode: .fill)
                case .failure:
                    Image(systemName: "music.note").font(.title2).foregroundColor(.white.opacity(0.4))
                default:
                    ProgressView().tint(.white)
                }
            }
            .frame(width: 56, height: 56)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isCurrentlyPlaying ? Color(hue: 0.78, saturation: 0.5, brightness: 1.0).opacity(0.7) : .clear, lineWidth: 1.5)
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(track.name)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text(track.artistNames)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.white.opacity(0.55))
                    .lineLimit(1)
                Text(track.album.name)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(.white.opacity(0.35))
                    .lineLimit(1)
            }

            Spacer()

            HStack(spacing: 14) {
                Button { appState.play(track: track) } label: {
                    Image(systemName: isCurrentlyPlaying && appState.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(
                            isCurrentlyPlaying
                                ? LinearGradient(colors: [Color(hue: 0.78, saturation: 0.6, brightness: 1.0),
                                                           Color(hue: 0.60, saturation: 0.7, brightness: 0.9)],
                                                  startPoint: .top, endPoint: .bottom)
                                : LinearGradient(colors: [.white.opacity(0.5), .white.opacity(0.3)],
                                                  startPoint: .top, endPoint: .bottom)
                        )
                }

                Button { withAnimation(.spring(response: 0.3)) { appState.toggleFavorite(track) } } label: {
                    Image(systemName: isFav ? "heart.fill" : "heart")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(isFav ? Color(hue: 0.93, saturation: 0.7, brightness: 0.95) : .white.opacity(0.4))
                        .scaleEffect(isFav ? 1.15 : 1.0)
                }
            }
        }
        .padding(14)
        .background(.white.opacity(isCurrentlyPlaying ? 0.12 : 0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isCurrentlyPlaying ? Color(hue: 0.78, saturation: 0.4, brightness: 0.9).opacity(0.4) : .clear, lineWidth: 1)
        )
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.2), value: isPressed)
        .contextMenu {
            Button {
                if let url = track.spotifyURL { UIApplication.shared.open(url) }
            } label: {
                Label("Open in Spotify", systemImage: "music.note")
            }
            Button(role: isFav ? .destructive : .none) {
                appState.toggleFavorite(track)
            } label: {
                Label(isFav ? "Remove Favourite" : "Add to Favourites",
                      systemImage: isFav ? "heart.slash" : "heart")
            }
        }
    }
}
