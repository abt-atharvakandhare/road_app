//
//  CarPlayMarkerGenerator.swift
//  Runner
//

import UIKit

/// Generates CarPlay map markers with letter labels (A-L) composited onto the base pin images.
/// Caches generated images so each variant is only rendered once per session.
class CarPlayMarkerGenerator {
    static let shared = CarPlayMarkerGenerator()

    /// Cache keyed by "\(status)-\(letter)" e.g. "available-A"
    private var cache: [String: UIImage] = [:]

    /// Letters used for labeling stations (max 12 for CarPlay POI limit)
    static let letters = Array("ABCDEFGHIJKL")

    /// Returns the letter for a given station index (0-based), or nil if out of range.
    static func letter(for index: Int) -> String? {
        guard index >= 0 && index < letters.count else { return nil }
        return String(letters[index])
    }

    /// Returns a marker image with the given letter composited onto the base marker for the status.
    func markerImage(for status: EvseStatus, letter: String) -> UIImage? {
        let key = "\(status)-\(letter)"
        if let cached = cache[key] {
            return cached
        }

        let baseName: String
        switch status {
        case .available:
            baseName = "CarPlayMarkerAvailable"
        case .charging:
            baseName = "CarPlayMarkerCharging"
        case .unknown:
            baseName = "CarPlayMarkerUnknown"
        }

        guard let baseImage = UIImage(named: baseName) else { return nil }
        let result = composeLetter(letter, onto: baseImage)
        cache[key] = result
        return result
    }

    /// Returns a selected marker image with the given letter.
    func selectedMarkerImage(letter: String) -> UIImage? {
        let key = "selected-\(letter)"
        if let cached = cache[key] {
            return cached
        }

        guard let baseImage = UIImage(named: "CarPlayMarkerSelected") else { return nil }
        let result = composeLetter(letter, onto: baseImage, textColor: .darkGray).withRenderingMode(.alwaysOriginal)
        cache[key] = result
        return result
    }

    /// Draws the letter centered in the circular head of the pin marker.
    private func composeLetter(_ letter: String, onto baseImage: UIImage, textColor: UIColor = .white) -> UIImage {
        let size = baseImage.size
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            // Draw the base marker
            baseImage.draw(at: .zero)

            // The circular head of the pin occupies roughly the top 60% of the image,
            // but the visual center of the circle sits slightly below the geometric center
            // due to the pin's drop-shadow and top padding.
            let circleHeight = size.height * 0.6
            let circleCenterY = (circleHeight / 2.0) + (size.height * 0.07)

            let fontSize = circleHeight * 0.55
            let font = UIFont.systemFont(ofSize: fontSize, weight: .bold)

            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: textColor
            ]

            let textSize = (letter as NSString).size(withAttributes: attributes)
            let textX = (size.width - textSize.width) / 2.0
            let textY = circleCenterY - (textSize.height / 2.0)

            (letter as NSString).draw(at: CGPoint(x: textX, y: textY), withAttributes: attributes)
        }
    }
}
