# MoodMuse 🎵

An iOS app that recommends Spotify music based on how you're feeling — detected manually, through text, or by analysing your facial expression via the camera.

---

## Features

- **Mood Picker** — choose from six moods (Happy, Sad, Calm, Energetic, Angry, Romantic) with a single tap
- **Text Input** — describe how you feel in your own words and the app maps it to the nearest mood
- **Camera Detection** — take a selfie and Apple's Vision framework analyses your facial landmarks to detect your mood automatically
- **Spotify Recommendations** — fetches a personalised playlist via the Spotify Web API (`/recommendations` + `/search` fallback)
- **30-Second Previews** — stream preview clips directly in-app via AVPlayer
- **Open in Spotify** — deep-link any track straight to the Spotify app
- **Favourites** — heart any track to save it locally and sync it to your Spotify library
- **Recent Moods** — quick-access chips for your last five mood choices, persisted between sessions
- **Mini Player** — sticky playback bar above the tab bar while a preview is playing; swipe down to dismiss

---

## Tech Stack

| Layer | Technology |
|---|---|
| UI | SwiftUI |
| Authentication | Spotify OAuth 2.0 PKCE via `ASWebAuthenticationSession` |
| Music API | Spotify Web API |
| Face Detection | Apple Vision (`VNDetectFaceLandmarksRequest`) |
| Playback | AVFoundation (`AVPlayer`) |
| Persistence | UserDefaults (favourites, recent moods) · Keychain (auth tokens) |
| Min. iOS | iOS 16 |

No third-party dependencies — only Apple system frameworks.

---

## Project Structure

```
MoodMuse/
├── Config.swift              ← Spotify credentials
├── AppState.swift            ← Global observable state + AVPlayer
├── MoodMuseApp.swift         ← App entry point + OAuth URL handler
├── ContentView.swift         ← Root navigator
├── Info.plist                ← Camera permission + URL scheme
├── Models/
│   ├── Mood.swift
│   ├── Track.swift
│   └── AuthToken.swift
├── Services/
│   ├── KeychainHelper.swift
│   ├── SpotifyAuthService.swift
│   ├── SpotifyAPIService.swift
│   ├── FaceAnalysisService.swift
│   └── StorageService.swift
└── Views/
    ├── SpotifyLoginView.swift
    ├── MainTabView.swift
    ├── MoodInputView.swift
    ├── CameraView.swift
    ├── RecommendationsView.swift
    ├── TrackRowView.swift
    ├── FavoritesView.swift
    └── PlayerBarView.swift
```

---

## Setup

### 1. Spotify Developer Account

1. Go to [developer.spotify.com/dashboard](https://developer.spotify.com/dashboard) and create an app
2. Under **Edit Settings → Redirect URIs**, add `moodmuse://callback`
3. Under **Users and Access**, add your Spotify account email (required while in Development Mode)

### 2. Add Your Client ID

Copy `Config.swift.template` to `Config.swift` and fill in your Client ID:

```swift
static let clientID = "YOUR_SPOTIFY_CLIENT_ID"
```

> `Config.swift` is gitignored — never commit real credentials.

### 3. Xcode Signing

Open `MoodMuse.xcodeproj`, select the **MoodMuse** target → **Signing & Capabilities**, and set your Apple Developer Team.

### 4. Run

Select a simulator or device and press **Cmd+R**.

> Camera-based mood detection requires a physical device. The simulator falls back to the photo library.

---

## How It Works

```
User selects mood  ──┐
User types text    ──┤── AppState.fetchRecommendations()
Camera + Vision    ──┘         │
                               ▼
                   Spotify /recommendations
                         (fallback: /search)
                               │
                               ▼
                   RecommendationsView ─── ♥ ──► Favourites + Spotify library
                               │
                               ▼
                   AVPlayer (30s preview) / Spotify deep link
```
