// Config.swift
// MoodMuse

import Foundation

enum SpotifyConfig {
    static let clientID    = "2fb278b940704069ab0a6d2b72f64f10"
    static let redirectURI = "moodmuse://callback"

    static let scopes = [
        "user-library-read",
        "user-library-modify",
        "user-read-playback-state",
        "user-modify-playback-state",
        "playlist-read-private",
        "streaming"
    ].joined(separator: " ")

    static let authorizationURL = URL(string: "https://accounts.spotify.com/authorize")!
    static let tokenURL         = URL(string: "https://accounts.spotify.com/api/token")!
    static let apiBaseURL       = URL(string: "https://api.spotify.com/v1")!
}
