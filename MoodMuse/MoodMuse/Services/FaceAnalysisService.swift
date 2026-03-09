// FaceAnalysisService.swift
// MoodMuse

import Vision
import UIKit

final class FaceAnalysisService {

    enum FaceError: LocalizedError {
        case noFaceDetected, processingFailed(Error)
        var errorDescription: String? {
            switch self {
            case .noFaceDetected:          return "No face detected — please try again in better lighting."
            case .processingFailed(let e): return e.localizedDescription
            }
        }
    }

    func analyzeMood(from image: UIImage) async throws -> Mood {
        guard let cg = image.cgImage else { throw FaceError.noFaceDetected }
        return try await withCheckedThrowingContinuation { continuation in
            let req = VNDetectFaceLandmarksRequest { req, error in
                if let error { continuation.resume(throwing: FaceError.processingFailed(error)); return }
                guard let obs = req.results as? [VNFaceObservation], let face = obs.first else {
                    continuation.resume(throwing: FaceError.noFaceDetected)
                    return
                }
                continuation.resume(returning: Self.classify(face))
            }
            let handler = VNImageRequestHandler(
                cgImage: cg,
                orientation: Self.cgOrientation(from: image),
                options: [:]
            )
            do    { try handler.perform([req]) }
            catch { continuation.resume(throwing: FaceError.processingFailed(error)) }
        }
    }

    private static func classify(_ face: VNFaceObservation) -> Mood {
        guard let landmarks = face.landmarks,
              let outerLips = landmarks.outerLips else { return .calm }

        let pts = outerLips.normalizedPoints
        guard pts.count >= 8 else { return .calm }

        let leftCorner   = pts[0]
        let rightCorner  = pts[pts.count / 2]
        let topMid       = pts[pts.count / 4]
        let botMid       = pts[pts.count * 3 / 4]

        let cornerMidY   = CGFloat(leftCorner.y + rightCorner.y) / 2.0
        let mouthCenterY = CGFloat(topMid.y + botMid.y) / 2.0
        let delta        = cornerMidY - mouthCenterY

        var browTense = false
        if let leftBrow  = landmarks.leftEyebrow,
           let rightBrow = landmarks.rightEyebrow {
            let lAvg = leftBrow.normalizedPoints.map(\.y).reduce(0, +) / CGFloat(leftBrow.pointCount)
            let rAvg = rightBrow.normalizedPoints.map(\.y).reduce(0, +) / CGFloat(rightBrow.pointCount)
            browTense = (lAvg + rAvg) / 2.0 < 0.75
        }

        switch delta {
        case let d where d > 0.015:  return .happy
        case let d where d < -0.015: return browTense ? .angry : .sad
        default:                     return browTense ? .energetic : .calm
        }
    }

    private static func cgOrientation(from image: UIImage) -> CGImagePropertyOrientation {
        switch image.imageOrientation {
        case .up:            return .up
        case .down:          return .down
        case .left:          return .left
        case .right:         return .right
        case .upMirrored:    return .upMirrored
        case .downMirrored:  return .downMirrored
        case .leftMirrored:  return .leftMirrored
        case .rightMirrored: return .rightMirrored
        @unknown default:    return .up
        }
    }
}
