import Foundation
import Combine

@MainActor
final class PlaybackHistory: ObservableObject {
    static let shared = PlaybackHistory()
    private static let storageKey = "recentlyPlayedSongFilenames"
    private let defaults: UserDefaults

    @Published private(set) var filenames: [String]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        var seen = Set<String>()
        filenames = Array((defaults.stringArray(forKey: Self.storageKey) ?? [])
            .filter { seen.insert($0).inserted }.prefix(6))
    }

    // Called only after the audio player confirms playback started successfully.
    func record(_ song: Song) {
        filenames = Array(([song.filename] + filenames.filter { $0 != song.filename }).prefix(6))
        defaults.set(filenames, forKey: Self.storageKey)
    }

    func songs(in playlists: [Playlist]) -> [Song] {
        let songs = playlists.flatMap(\.songs)
        // CSV models have new UUIDs on launch; filenames identify tracks across launches.
        return filenames.compactMap { filename in songs.first { $0.filename == filename } }
    }
}
