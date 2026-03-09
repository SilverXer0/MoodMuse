// MoodInputView.swift
// MoodMuse

import SwiftUI

struct MoodInputView: View {
    @EnvironmentObject var appState: AppState
    @State private var textInput = ""
    @State private var showCamera = false
    @State private var cameraErrorMessage: String?
    @State private var showError = false
    @FocusState private var textFocused: Bool

    private let bg = Color(red: 0.05, green: 0.04, blue: 0.14)

    var body: some View {
        NavigationStack {
            ZStack {
                bg.ignoresSafeArea()

                if let mood = appState.currentMood {
                    Circle()
                        .fill(mood.color.opacity(0.18))
                        .frame(width: 350)
                        .blur(radius: 90)
                        .offset(y: -80)
                        .animation(.easeInOut(duration: 0.6), value: appState.currentMood)
                }

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {

                        VStack(alignment: .leading, spacing: 6) {
                            Text("How are you")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text("feeling today?")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(hue: 0.78, saturation: 0.5, brightness: 1.0),
                                                 Color(hue: 0.60, saturation: 0.6, brightness: 0.9)],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                )
                        }
                        .padding(.top, 16)

                        VStack(alignment: .leading, spacing: 12) {
                            sectionLabel("Pick a mood")
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(Mood.allCases) { mood in
                                        MoodChip(mood: mood, isSelected: appState.currentMood == mood) {
                                            selectMood(mood)
                                        }
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            sectionLabel("Or describe it")
                            HStack(spacing: 12) {
                                TextField("e.g. feeling happy and excited...", text: $textInput)
                                    .font(.system(size: 15, design: .rounded))
                                    .foregroundColor(.white)
                                    .focused($textFocused)
                                    .onSubmit { submitText() }
                                if !textInput.isEmpty {
                                    Button(action: submitText) {
                                        Image(systemName: "arrow.up.circle.fill")
                                            .font(.system(size: 30))
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [Color(hue: 0.78, saturation: 0.6, brightness: 1.0),
                                                             Color(hue: 0.60, saturation: 0.7, brightness: 0.9)],
                                                    startPoint: .top, endPoint: .bottom
                                                )
                                            )
                                    }
                                }
                            }
                            .padding(14)
                            .background(.white.opacity(0.07))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(textFocused ? Color(hue: 0.78, saturation: 0.5, brightness: 0.9).opacity(0.6) : .white.opacity(0.12), lineWidth: 1)
                            )
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            sectionLabel("Detect from selfie")
                            Button { showCamera = true } label: {
                                HStack(spacing: 14) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hue: 0.78, saturation: 0.6, brightness: 0.9).opacity(0.2))
                                            .frame(width: 48, height: 48)
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(Color(hue: 0.78, saturation: 0.5, brightness: 1.0))
                                    }
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("Use Camera")
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)
                                        Text("Smile, frown, or just look natural")
                                            .font(.system(size: 13, design: .rounded))
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.3))
                                }
                                .padding(16)
                                .background(.white.opacity(0.07))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }

                        if !appState.recentMoods.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                sectionLabel("Recent moods")
                                HStack(spacing: 10) {
                                    ForEach(appState.recentMoods) { mood in
                                        Button { selectMood(mood) } label: {
                                            HStack(spacing: 6) {
                                                Text(mood.emoji).font(.system(size: 14))
                                                Text(mood.displayName)
                                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                                    .foregroundColor(.white.opacity(0.85))
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(mood.color.opacity(0.18))
                                            .clipShape(Capsule())
                                            .overlay(Capsule().stroke(mood.color.opacity(0.4), lineWidth: 1))
                                        }
                                    }
                                }
                            }
                        }

                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal, 22)
                }

                if appState.isLoading {
                    Color.black.opacity(0.5).ignoresSafeArea()
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                            .scaleEffect(1.4)
                        Text("Finding your vibe…")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showCamera) {
                CameraView(
                    isPresented: $showCamera,
                    onMoodDetected: { mood in selectMood(mood) },
                    onError: { msg in cameraErrorMessage = msg; showError = true }
                )
                .environmentObject(appState)
                .ignoresSafeArea()
            }
            .alert("Camera Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(cameraErrorMessage ?? "Unknown error")
            }
            .alert("Error", isPresented: .init(
                get: { appState.errorMessage != nil },
                set: { if !$0 { appState.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(appState.errorMessage ?? "")
            }
            .navigationDestination(isPresented: $appState.showRecommendations) {
                RecommendationsView()
            }
        }
    }

    private func selectMood(_ mood: Mood) {
        textFocused = false
        appState.showRecommendations = false
        Task { await appState.fetchRecommendations(for: mood) }
    }

    private func submitText() {
        guard !textInput.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let mood = Mood.from(text: textInput)
        textInput = ""
        selectMood(mood)
    }

    @ViewBuilder
    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .foregroundColor(.white.opacity(0.4))
            .kerning(1)
    }
}

struct MoodChip: View {
    let mood: Mood
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(mood.emoji).font(.system(size: 18))
                Text(mood.displayName)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(isSelected ? .black : .white)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(
                isSelected
                    ? AnyShapeStyle(mood.color)
                    : AnyShapeStyle(Color.white.opacity(0.09))
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? .clear : mood.color.opacity(0.35), lineWidth: 1)
            )
            .shadow(color: isSelected ? mood.color.opacity(0.5) : .clear, radius: 12)
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
    }
}

#Preview {
    MoodInputView().environmentObject(AppState())
}
