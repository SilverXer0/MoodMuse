// SpotifyAuthService.swift
// MoodMuse

import Foundation
import AuthenticationServices
import CryptoKit
import UIKit

@MainActor
final class SpotifyAuthService: NSObject, ObservableObject {

    @Published var isAuthenticated = false
    private(set) var currentToken: AuthToken?

    private var authSession: ASWebAuthenticationSession?
    private var codeVerifier: String?

    private let kcService = "com.moodmuse.app"
    private let kcAccount = "spotifyToken"

    override init() {
        super.init()
        loadStoredToken()
    }

    // MARK: - Auth Flow

    func startAuthFlow() {
        let verifier = generateCodeVerifier()
        codeVerifier = verifier
        let challenge = codeChallenge(from: verifier)
        let state = UUID().uuidString

        var comps = URLComponents(url: SpotifyConfig.authorizationURL, resolvingAgainstBaseURL: false)!
        comps.queryItems = [
            URLQueryItem(name: "client_id",             value: SpotifyConfig.clientID),
            URLQueryItem(name: "response_type",         value: "code"),
            URLQueryItem(name: "redirect_uri",          value: SpotifyConfig.redirectURI),
            URLQueryItem(name: "scope",                 value: SpotifyConfig.scopes),
            URLQueryItem(name: "state",                 value: state),
            URLQueryItem(name: "code_challenge",        value: challenge),
            URLQueryItem(name: "code_challenge_method", value: "S256")
        ]
        guard let authURL = comps.url,
              let scheme = URL(string: SpotifyConfig.redirectURI)?.scheme else { return }

        let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: scheme) { [weak self] url, error in
            guard let self, error == nil, let url else { return }
            Task { await self.handleCallback(url: url) }
        }
        session.presentationContextProvider = self
        session.prefersEphemeralWebBrowserSession = false
        authSession = session
        session.start()
    }

    func handleCallback(url: URL) async {
        guard let comps = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let code = comps.queryItems?.first(where: { $0.name == "code" })?.value,
              let verifier = codeVerifier else { return }
        do {
            let token = try await exchangeCode(code, verifier: verifier)
            persist(token)
            currentToken = token
            isAuthenticated = true
        } catch {
            print("[SpotifyAuth] Token exchange failed: \(error)")
        }
    }

    func getValidAccessToken() async throws -> String {
        guard let token = currentToken else { throw AuthError.notAuthenticated }
        if token.isExpired { return try await refresh(token).accessToken }
        return token.accessToken
    }

    func logout() {
        KeychainHelper.delete(service: kcService, account: kcAccount)
        currentToken = nil
        isAuthenticated = false
    }

    // MARK: - PKCE

    private func generateCodeVerifier() -> String {
        var bytes = [UInt8](repeating: 0, count: 64)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return String(
            Data(bytes).base64EncodedString()
                .replacingOccurrences(of: "+", with: "-")
                .replacingOccurrences(of: "/", with: "_")
                .replacingOccurrences(of: "=", with: "")
                .prefix(128)
        )
    }

    private func codeChallenge(from verifier: String) -> String {
        Data(SHA256.hash(data: Data(verifier.utf8)))
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    // MARK: - Token Exchange

    private func exchangeCode(_ code: String, verifier: String) async throws -> AuthToken {
        var req = URLRequest(url: SpotifyConfig.tokenURL)
        req.httpMethod = "POST"
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        req.httpBody = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": SpotifyConfig.redirectURI,
            "client_id": SpotifyConfig.clientID,
            "code_verifier": verifier
        ].urlEncoded

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else { throw AuthError.tokenExchangeFailed }
        return AuthToken(from: try JSONDecoder().decode(TokenResponse.self, from: data))
    }

    private func refresh(_ token: AuthToken) async throws -> AuthToken {
        guard let refreshToken = token.refreshToken else { throw AuthError.noRefreshToken }
        var req = URLRequest(url: SpotifyConfig.tokenURL)
        req.httpMethod = "POST"
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        req.httpBody = [
            "grant_type":    "refresh_token",
            "refresh_token": refreshToken,
            "client_id":     SpotifyConfig.clientID
        ].urlEncoded

        let (data, _) = try await URLSession.shared.data(for: req)
        let newToken = AuthToken(from: try JSONDecoder().decode(TokenResponse.self, from: data))
        persist(newToken)
        currentToken = newToken
        return newToken
    }

    // MARK: - Persistence

    private func persist(_ token: AuthToken) {
        guard let data = try? JSONEncoder().encode(token) else { return }
        KeychainHelper.save(data, service: kcService, account: kcAccount)
    }

    private func loadStoredToken() {
        guard let data = KeychainHelper.read(service: kcService, account: kcAccount),
              let token = try? JSONDecoder().decode(AuthToken.self, from: data) else { return }
        currentToken = token
        isAuthenticated = !token.isExpired || token.refreshToken != nil
    }
}

extension SpotifyAuthService: ASWebAuthenticationPresentationContextProviding {
    nonisolated func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow) ?? UIWindow()
    }
}

enum AuthError: LocalizedError {
    case notAuthenticated, tokenExchangeFailed, noRefreshToken
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:    return "Not authenticated with Spotify"
        case .tokenExchangeFailed: return "Failed to exchange authorization code"
        case .noRefreshToken:      return "No refresh token available – please log in again"
        }
    }
}

private extension Dictionary where Key == String, Value == String {
    var urlEncoded: Data? {
        map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
            .joined(separator: "&")
            .data(using: .utf8)
    }
}
