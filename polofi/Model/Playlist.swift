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
    
    init(id: UUID = UUID(), name: String, songs: [Song]) {
        self.id = id
        self.name = name
        self.songs = songs
    }
    
    // MARK: Mock Data
    static let mockData: [Playlist] = [
        Playlist(name: "Playlist 1", songs: [
            Song(title: "Bluewave - A Better Future", filename: "Bluewave-A Better Future.mp3"),
            Song(title: "Dagored - Quiet Fields", filename: "Dagored-Quiet Fields.mp3"),
        ]),
        
        Playlist(name: "Playlist 2", songs: [
            Song(title: "Hazelwood - At Ease", filename: "Hazelwood-At Ease.mp3"),
            Song(title: "Pufino - Enjoy", filename: "Pufino-Enjoy.mp3"),
        ]),
        
        Playlist(name: "Playlist 3", songs: [
            Song(title: "Spiring - City Life", filename: "Spiring-City Life.mp3"),
            Song(title: "Aylex - Happy Moments", filename: "Aylex-Happy Moments.mp3"),
        ]),

        Playlist(name: "Playlist 4", songs: [
            Song(title: "Moavii - Sunset Dreams", filename: "Moavii-Sunset Dreams.mp3"),
            Song(title: "Piki - Fancy Park", filename: "Piki-Fancy Park.mp3"),
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
