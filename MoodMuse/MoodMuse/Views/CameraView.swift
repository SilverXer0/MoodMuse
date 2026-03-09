// CameraView.swift
// MoodMuse

import SwiftUI
import UIKit

struct CameraView: UIViewControllerRepresentable {
    @EnvironmentObject var appState: AppState
    @Binding var isPresented: Bool
    var onMoodDetected: (Mood) -> Void
    var onError: (String) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        picker.cameraCaptureMode = .photo
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraView

        init(_ parent: CameraView) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            parent.isPresented = false
            guard let image = info[.originalImage] as? UIImage else { return }
            Task { @MainActor in
                do {
                    let mood = try await parent.appState.face.analyzeMood(from: image)
                    parent.onMoodDetected(mood)
                } catch {
                    parent.onError(error.localizedDescription)
                }
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}
