//
//  Playlist.swift
//  polofi
//
//  Created by Amelia Citra on 02/04/26.
//

import Foundation
import SwiftUI

struct Playlist: Identifiable {
    let id: UUID
    let name: String
    let songs: [Song]
    
    init(id: UUID = UUID(), name: String, songs: [Song]) {
        self.id = id
        self.name = name
        self.songs = songs
    }
    
    // MARK: Mock Data
    static let mockData: [Playlist] = [
        Playlist(name: "Playlist 1", songs: [
            Song(title: "Song 1", filename: "Songs1.mp3"),
            Song(title: "Song 2", filename: "Songs2.mp3"),
            Song(title: "Song 3", filename: "Songs3.mp3")
        ]),
        
        Playlist(name: "Playlist 2", songs: [
            Song(title: "Song 4", filename: "Song4.mp3"),
            Song(title: "Song 5", filename: "Song5.mp3"),
            Song(title: "Song 6", filename: "Song6.mp3"),
        ]),
        
        Playlist(name: "Playlist 3", songs: [
            Song(title: "Song 7", filename: "Song7.mp3"),
            Song(title: "Song 8", filename: "Song8.mp3"),
            Song(title: "Song 9", filename: "Song9.mp3"),
        ]),
    ]
}

#Preview {
    let playlists = Playlist.mockData
    ForEach (playlists) { playlist in
        Text(playlist.name)
        
        ForEach (playlist.songs) { song in
            Text(song.title)
        }
    }
    
//    let allSongs = Playlist.mockData.flatMap { $0.songs }
}
