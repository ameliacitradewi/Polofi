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
    
    init(id: UUID = UUID(), title: String, filename: String) {
        self.id = id
        self.title = title
        self.filename = filename
        self.artist = "Unknown Artist"
        self.duration = 0
    }
}
