//
//  Playlist.swift
//  polofi
//
//  Created by Amelia Citra on 02/04/26.
//

import Foundation

struct Playlist: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    let songs: [Song]
    let coverArt: String
    let description: String
    
    init(
        id: UUID = UUID(),
        name: String,
        songs: [Song],
        coverArt: String = "Cover1",
        description: String = ""
    ) {
        self.id = id
        self.name = name
        self.songs = songs
        self.coverArt = coverArt
        self.description = description
    }
}
