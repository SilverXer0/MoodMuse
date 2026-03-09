// SpotifyLoginView.swift
// MoodMuse

import SwiftUI

struct SpotifyLoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var logoScale: CGFloat = 0.7
    @State private var logoOpacity: Double = 0

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.04, blue: 0.14),
                    Color(red: 0.10, green: 0.06, blue: 0.22),
                    Color(red: 0.04, green: 0.04, blue: 0.10)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color(hue: 0.75, saturation: 0.7, brightness: 0.5).opacity(0.25))
                .frame(width: 300)
                .blur(radius: 80)
                .offset(x: -60, y: -200)

            Circle()
                .fill(Color(hue: 0.55, saturation: 0.8, brightness: 0.6).opacity(0.20))
                .frame(width: 250)
                .blur(radius: 80)
                .offset(x: 100, y: 250)

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hue: 0.75, saturation: 0.8, brightness: 0.9),
                                         Color(hue: 0.60, saturation: 0.7, brightness: 0.8)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 110, height: 110)
                        .shadow(color: Color(hue: 0.75, saturation: 0.8, brightness: 0.9).opacity(0.5), radius: 30)

                    Text("🎵")
                        .font(.system(size: 50))
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                .onAppear {
                    withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
                        logoScale   = 1.0
                        logoOpacity = 1.0
                    }
                }

                Spacer().frame(height: 36)

                VStack(spacing: 10) {
                    Text("MoodMuse")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, Color(hue: 0.78, saturation: 0.4, brightness: 1.0)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )

                    Text("Music that matches how you feel")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .opacity(logoOpacity)

                Spacer().frame(height: 60)

                VStack(spacing: 14) {
                    featureRow(icon: "face.smiling", label: "Detect your mood via camera")
                    featureRow(icon: "music.note.list", label: "Get Spotify recommendations")
                    featureRow(icon: "heart.fill",    label: "Save your favourite tracks")
                }
                .padding(.horizontal, 32)
                .opacity(logoOpacity)

                Spacer()

                Button {
                    appState.auth.startAuthFlow()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "music.note")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Connect with Spotify")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.11, green: 0.84, blue: 0.45),
                                     Color(red: 0.05, green: 0.70, blue: 0.35)],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: Color(red: 0.11, green: 0.84, blue: 0.45).opacity(0.5), radius: 20)
                }
                .padding(.horizontal, 28)
                .opacity(logoOpacity)

                Spacer().frame(height: 50)
            }
        }
    }

    @ViewBuilder
    private func featureRow(icon: String, label: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hue: 0.75, saturation: 0.6, brightness: 0.9))
                .frame(width: 32)
            Text(label)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.75))
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    SpotifyLoginView().environmentObject(AppState())
}
