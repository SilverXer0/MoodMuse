// Track.swift
// MoodMuse

import Foundation

struct SpotifySearchResponse: Codable {
    let tracks: TrackPage
}

struct TrackPage: Codable {
    let items: [Track]
    let total: Int
}

struct SpotifyRecommendationsResponse: Codable {
    let tracks: [Track]
}

struct SavedTrackPage: Codable {
    let items: [SavedTrackItem]
    let total: Int
}

struct SavedTrackItem: Codable {
    let track: Track
    let addedAt: String
    enum CodingKeys: String, CodingKey {
        case track
        case addedAt = "added_at"
    }
}

struct Track: Codable, Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let artists: [Artist]
    let album: Album
    let previewUrl: String?
    let externalUrls: ExternalURLs
    let durationMs: Int
    let uri: String
    let popularity: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, artists, album, uri, popularity
        case previewUrl = "preview_url"
        case externalUrls = "external_urls"
        case durationMs = "duration_ms"
    }

    var artistNames: String { artists.map(\.name).joined(separator: ", ") }

    var albumArtURL: URL? {
        let img = album.images.first { ($0.width ?? 0) >= 200 && ($0.width ?? 0) <= 500 }
                  ?? album.images.first
        return img.flatMap { URL(string: $0.url) }
    }

    var spotifyURL: URL? { URL(string: externalUrls.spotify) }

    var formattedDuration: String {
        let s = durationMs / 1000
        return String(format: "%d:%02d", s / 60, s % 60)
    }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct Artist: Codable, Equatable, Hashable {
    let id: String
    let name: String
}

struct Album: Codable, Equatable, Hashable {
    let id: String
    let name: String
    let images: [SpotifyImage]
}

struct SpotifyImage: Codable, Equatable, Hashable {
    let url: String
    let width: Int?
    let height: Int?
}

struct ExternalURLs: Codable, Equatable, Hashable {
    let spotify: String
}
