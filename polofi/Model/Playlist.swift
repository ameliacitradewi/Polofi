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
    
    init(
        id: UUID = UUID(),
        name: String,
        songs: [Song],
        coverArt: String = "Cover1"
    ) {
        self.id = id
        self.name = name
        self.songs = songs
        self.coverArt = coverArt
    }
    
    // MARK: Mock Data
    static let mockData: [Playlist] = [
        Playlist(name: "Calm", songs: [
            Song(title: "A Better Future", filename: "Bluewave-A Better Futur.mp3", artist: "Bluewave", albumArt: "AlbumArt"),
            Song(title: "Quiet Fields", filename: "Dagored-Quiet Fields.mp3", artist: "Dagored", albumArt: "AlbumArt"),
        ]),
        
        Playlist(name: "Study", songs: [
            Song(title: "At Ease", filename: "Hazelwood-At Ease.mp3", artist: "Hazelwood", albumArt: "AlbumArt"),
            Song(title: "Enjoy", filename: "Pufino-Enjoy.mp3", artist: "Pufino", albumArt: "AlbumArt"),
        ]),
        
        Playlist(name: "Chill", songs: [
            Song(title: "City Life", filename: "Spiring-City Life.mp3", artist: "Spiring", albumArt: "AlbumArt"),
            Song(title: "Happy Moments", filename: "Aylex-Happy Moments.mp3", artist: "Aylex", albumArt: "AlbumArt"),
        ]),

        Playlist(name: "Dreamy", songs: [
            Song(title: "Sunset Dreams", filename: "Moavii-Sunset Dreams.mp3", artist: "Moavii", albumArt: "AlbumArt"),
            Song(title: "Fancy Park", filename: "Piki-Fancy Park.mp3", artist: "Piki", albumArt: "AlbumArt"),
        ]),
    ]
}

//#Preview {
//    let playlists = Playlist.mockData
//    ForEach (playlists) { playlist in
//        Text(playlist.name)
//        
//        ForEach (playlist.songs) { song in
//            Text(song.title)
//        }
//    }
//    
////    let allSongs = Playlist.mockData.flatMap { $0.songs }
//}
