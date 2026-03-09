// Mood.swift
// MoodMuse

import SwiftUI

enum Mood: String, CaseIterable, Codable, Identifiable {
    case happy, sad, calm, energetic, angry, romantic

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .happy:     return "Happy"
        case .sad:       return "Sad"
        case .calm:      return "Calm"
        case .energetic: return "Energetic"
        case .angry:     return "Angry"
        case .romantic:  return "Romantic"
        }
    }

    var emoji: String {
        switch self {
        case .happy:     return "😊"
        case .sad:       return "😢"
        case .calm:      return "😌"
        case .energetic: return "⚡️"
        case .angry:     return "😤"
        case .romantic:  return "🥰"
        }
    }

    var color: Color {
        switch self {
        case .happy:     return Color(hue: 0.12, saturation: 0.95, brightness: 1.00)
        case .sad:       return Color(hue: 0.60, saturation: 0.65, brightness: 0.85)
        case .calm:      return Color(hue: 0.50, saturation: 0.55, brightness: 0.80)
        case .energetic: return Color(hue: 0.07, saturation: 1.00, brightness: 1.00)
        case .angry:     return Color(hue: 0.00, saturation: 0.90, brightness: 0.90)
        case .romantic:  return Color(hue: 0.93, saturation: 0.70, brightness: 0.95)
        }
    }

    var gradient: LinearGradient {
        LinearGradient(colors: [color, color.opacity(0.55)],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var searchQuery: String {
        switch self {
        case .happy:     return "happy upbeat feel good pop"
        case .sad:       return "sad emotional heartbreak"
        case .calm:      return "calm peaceful ambient relaxing"
        case .energetic: return "energetic hype workout"
        case .angry:     return "angry intense aggressive"
        case .romantic:  return "romantic love ballad"
        }
    }

    var seedGenres: [String] {
        switch self {
        case .happy:     return ["pop", "dance", "happy"]
        case .sad:       return ["sad", "blues", "acoustic"]
        case .calm:      return ["ambient", "chill", "sleep"]
        case .energetic: return ["edm", "hip-hop", "rock"]
        case .angry:     return ["metal", "punk", "alternative"]
        case .romantic:  return ["romance", "r-n-b", "soul"]
        }
    }

    static func from(text: String) -> Mood {
        let lower = text.lowercased()
        let keywords: [(words: [String], mood: Mood)] = [
            (["happy", "joy", "great", "amazing", "excited", "wonderful", "fantastic", "good", "cheerful", "glad", "elated"], .happy),
            (["sad", "depressed", "down", "blue", "unhappy", "cry", "lonely", "miss", "heartbroken", "melancholy", "grief"], .sad),
            (["calm", "peaceful", "relaxed", "chill", "serene", "quiet", "tranquil", "zen", "mellow", "still"], .calm),
            (["energy", "energetic", "pump", "hyped", "motivated", "workout", "active", "run", "power", "hype", "fired"], .energetic),
            (["angry", "mad", "furious", "frustrated", "annoyed", "rage", "irritated"], .angry),
            (["romantic", "love", "crush", "affection", "tender", "date", "heart", "sweet", "adore"], .romantic)
        ]
        for entry in keywords {
            if entry.words.contains(where: { lower.contains($0) }) { return entry.mood }
        }
        return .calm
    }
}
