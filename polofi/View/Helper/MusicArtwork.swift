import SwiftUI
import UIKit

extension Image {
    static func musicArtwork(named name: String) -> Image {
        if let image = UIImage(named: name) {
            return Image(uiImage: image)
        }
        // Artwork imported as a Data Set must be decoded before SwiftUI can display it.
        if let asset = NSDataAsset(name: name), let image = UIImage(data: asset.data) {
            return Image(uiImage: image)
        }
        return Image(systemName: "music.note")
    }
}
