//
//  Song.swift
//  polofi
//
//  Created by Amelia Citra on 02/04/26.
//

import Foundation

struct Song: Identifiable, Hashable, Codable {
    let id: UUID
    let title: String
    let filename: String
    let artist: String
    let duration: TimeInterval
    let albumArt: String
    
    init(
        id: UUID = UUID(),
        title: String,
        filename: String,
        artist: String = "Unknown Artist",
        duration: TimeInterval = 0,
        albumArt: String = "AlbumArt"
    ) {
        self.id = id
        self.title = title
        self.filename = filename
        self.artist = artist
        self.duration = duration
        self.albumArt = albumArt
    }
}
