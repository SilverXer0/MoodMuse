// StorageService.swift
// MoodMuse

import Foundation

final class StorageService {

    private let defaults = UserDefaults.standard
    private let favKey = "mm_favorite_tracks"
    private let moodKey = "mm_recent_moods"

    // MARK: - Favourites

    func getFavorites() -> [Track] {
        guard let data = defaults.data(forKey: favKey),
              let tracks = try? JSONDecoder().decode([Track].self, from: data)
        else { return [] }
        return tracks
    }

    func saveToFavorites(_ track: Track) {
        var favs = getFavorites()
        guard !favs.contains(where: { $0.id == track.id }) else { return }
        favs.insert(track, at: 0)
        persist(favs, key: favKey)
    }

    func removeFromFavorites(id: String) {
        let favs = getFavorites().filter { $0.id != id }
        persist(favs, key: favKey)
    }

    func isFavorite(id: String) -> Bool {
        getFavorites().contains(where: { $0.id == id })
    }

    // MARK: - Recent Moods

    func getRecentMoods() -> [Mood] {
        guard let data = defaults.data(forKey: moodKey),
              let moods = try? JSONDecoder().decode([Mood].self, from: data)
        else { return [] }
        return moods
    }

    func addRecentMood(_ mood: Mood) {
        var moods = getRecentMoods().filter { $0 != mood }
        moods.insert(mood, at: 0)
        persist(Array(moods.prefix(5)), key: moodKey)
    }

    private func persist<T: Encodable>(_ value: T, key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        defaults.set(data, forKey: key)
    }
}
