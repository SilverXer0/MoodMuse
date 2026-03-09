// AuthToken.swift
// MoodMuse

import Foundation

struct AuthToken: Codable {
    let accessToken: String
    let refreshToken: String?
    let expiresAt: Date
    let tokenType: String

    var isExpired: Bool {
        Date() >= expiresAt.addingTimeInterval(-60)
    }

    init(from response: TokenResponse) {
        self.accessToken = response.accessToken
        self.refreshToken = response.refreshToken
        self.expiresAt = Date().addingTimeInterval(TimeInterval(response.expiresIn))
        self.tokenType = response.tokenType
    }
}

struct TokenResponse: Codable {
    let accessToken: String
    let tokenType: String
    let scope: String?
    let expiresIn: Int
    let refreshToken: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
    }
}
