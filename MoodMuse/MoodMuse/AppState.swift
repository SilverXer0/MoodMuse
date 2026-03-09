// AppState.swift
// MoodMuse

import SwiftUI
import AVFoundation

@MainActor
final class AppState: ObservableObject {

    let auth = SpotifyAuthService()
    let api: SpotifyAPIService
    let storage = StorageService()
    let face = FaceAnalysisService()

    @Published var currentMood: Mood?
    @Published var tracks: [Track] = []
    @Published var favorites: [Track] = []
    @Published var recentMoods: [Mood] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showRecommendations = false

    @Published var playingTrack: Track?
    @Published var isPlaying = false
    private var player: AVPlayer?
    private var playerObserver: Any?

    init() {
        api = SpotifyAPIService(auth: auth)
        favorites = storage.getFavorites()
        recentMoods = storage.getRecentMoods()
    }

    // MARK: - Recommendations

    func fetchRecommendations(for mood: Mood) async {
        currentMood = mood
        storage.addRecentMood(mood)
        recentMoods = storage.getRecentMoods()
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let fetched: [Track]
            do {
                fetched = try await api.getRecommendations(seedGenres: mood.seedGenres)
            } catch {
                fetched = try await api.searchTracks(query: mood.searchQuery)
            }
            tracks = fetched
            showRecommendations = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Favourites

    func toggleFavorite(_ track: Track) {
        if storage.isFavorite(id: track.id) {
            storage.removeFromFavorites(id: track.id)
            Task { try? await api.unsaveTrack(id: track.id) }
        } else {
            storage.saveToFavorites(track)
            Task { try? await api.saveTrack(id: track.id) }
        }
        favorites = storage.getFavorites()
    }

    func isFavorite(_ track: Track) -> Bool {
        storage.isFavorite(id: track.id)
    }

    // MARK: - Playback

    func play(track: Track) {
        guard let urlString = track.previewUrl, let url = URL(string: urlString) else {
            if let spotifyURL = track.spotifyURL { UIApplication.shared.open(spotifyURL) }
            return
        }

        playerObserver.map(NotificationCenter.default.removeObserver)
        player?.pause()
        player = AVPlayer(url: url)
        playingTrack = track
        isPlaying = true
        player?.play()

        playerObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { [weak self] _ in
            self?.isPlaying = false
            self?.playingTrack = nil
        }

        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func togglePlayPause() {
        guard player != nil else { return }
        if isPlaying { player?.pause(); isPlaying = false }
        else         { player?.play();  isPlaying = true  }
    }

    func stopPlayback() {
        player?.pause()
        player = nil
        isPlaying = false
        playingTrack = nil
        playerObserver.map(NotificationCenter.default.removeObserver)
    }
}
