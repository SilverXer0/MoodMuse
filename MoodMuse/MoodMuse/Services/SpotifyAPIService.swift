// SpotifyAPIService.swift
// MoodMuse

import Foundation

final class SpotifyAPIService {

    private let auth: SpotifyAuthService
    private let base = SpotifyConfig.apiBaseURL

    init(auth: SpotifyAuthService) { self.auth = auth }

    // MARK: - Search

    func searchTracks(query: String, limit: Int = 20) async throws -> [Track] {
        let url = try buildURL(path: "search", params: [
            "q": query, "type": "track", "limit": "\(limit)", "market": "US"
        ])
        let data = try await get(url)
        return try decode(SpotifySearchResponse.self, from: data).tracks.items
    }

    // MARK: - Recommendations

    func getRecommendations(seedGenres: [String], limit: Int = 20) async throws -> [Track] {
        let genres = seedGenres.prefix(5).joined(separator: ",")
        let url = try buildURL(path: "recommendations", params: [
            "seed_genres": genres, "limit": "\(limit)", "market": "US"
        ])
        let data = try await get(url)
        return try decode(SpotifyRecommendationsResponse.self, from: data).tracks
    }

    // MARK: - User Library

    func getUserSavedTracks(limit: Int = 50) async throws -> [Track] {
        let url = try buildURL(path: "me/tracks", params: ["limit": "\(limit)", "market": "US"])
        let data = try await get(url)
        return try decode(SavedTrackPage.self, from: data).items.map(\.track)
    }

    func saveTrack(id: String) async throws {
        try await put(base.appendingPathComponent("me/tracks"), body: ["ids": [id]])
    }

    func unsaveTrack(id: String) async throws {
        try await delete(base.appendingPathComponent("me/tracks"), body: ["ids": [id]])
    }

    func checkSavedTracks(ids: [String]) async throws -> [Bool] {
        let url = try buildURL(path: "me/tracks/contains", params: ["ids": ids.joined(separator: ",")])
        let data = try await get(url)
        return try JSONDecoder().decode([Bool].self, from: data)
    }

    // MARK: - Networking

    private func get(_ url: URL) async throws -> Data {
        var req = URLRequest(url: url)
        req.setValue("Bearer \(try await auth.getValidAccessToken())", forHTTPHeaderField: "Authorization")
        let (data, resp) = try await URLSession.shared.data(for: req)
        try validate(resp)
        return data
    }

    private func put(_ url: URL, body: [String: Any]) async throws {
        try await bodyRequest(url, method: "PUT", body: body)
    }

    private func delete(_ url: URL, body: [String: Any]) async throws {
        try await bodyRequest(url, method: "DELETE", body: body)
    }

    private func bodyRequest(_ url: URL, method: String, body: [String: Any]) async throws {
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("Bearer \(try await auth.getValidAccessToken())", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (_, resp) = try await URLSession.shared.data(for: req)
        try validate(resp)
    }

    private func validate(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        if http.statusCode == 401 { throw APIError.unauthorized }
        guard (200..<300).contains(http.statusCode) else { throw APIError.httpError(http.statusCode) }
    }

    private func buildURL(path: String, params: [String: String]) throws -> URL {
        var comps = URLComponents(url: base.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        comps.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        guard let url = comps.url else { throw APIError.invalidURL }
        return url
    }

    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(type, from: data)
    }
}

enum APIError: LocalizedError {
    case invalidURL, invalidResponse, unauthorized, httpError(Int)
    var errorDescription: String? {
        switch self {
        case .invalidURL:       return "Invalid URL"
        case .invalidResponse:  return "Invalid server response"
        case .unauthorized:     return "Spotify session expired — please log in again"
        case .httpError(let c): return "HTTP \(c)"
        }
    }
}
