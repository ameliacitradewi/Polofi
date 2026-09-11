import Foundation

@main
struct PlaybackHistoryTests {
    @MainActor
    static func main() {
        let suite = "PlaybackHistoryTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let history = PlaybackHistory(defaults: defaults)
        let songs = (1...8).map { Song(title: "Track \($0)", filename: "track\($0).mp3") }
        let playlist = Playlist(name: "Music", songs: songs)
        precondition(history.songs(in: [playlist]).isEmpty)

        // First playback appears immediately; recording over six tracks evicts the oldest.
        history.record(songs[0])
        precondition(history.songs(in: [playlist]).map(\.filename) == ["track1.mp3"])
        for song in songs.dropFirst() { history.record(song) }
        precondition(history.filenames == ["track8.mp3", "track7.mp3", "track6.mp3", "track5.mp3", "track4.mp3", "track3.mp3"])

        // Playing the same audio from another playlist moves it to the top without duplication.
        let duplicate = Song(title: "Track 5", filename: "track5.mp3")
        history.record(duplicate)
        history.record(duplicate)
        precondition(history.filenames == ["track5.mp3", "track8.mp3", "track7.mp3", "track6.mp3", "track4.mp3", "track3.mp3"])

        // Reload with fresh CSV UUIDs and edited metadata, as on a new app launch.
        let restored = PlaybackHistory(defaults: defaults)
        let updatedSongs = songs.map { Song(title: "Updated \($0.title)", filename: $0.filename) }
        let updatedPlaylist = Playlist(name: "Timer", songs: updatedSongs)
        precondition(restored.filenames == history.filenames)
        precondition(restored.songs(in: [updatedPlaylist]).first?.id == updatedSongs[4].id)
        precondition(restored.songs(in: [updatedPlaylist]).first?.title == "Updated Track 5")

        // Removed files are not rendered and the same track in multiple playlists appears once.
        let reducedPlaylist = Playlist(name: "Reduced", songs: [updatedSongs[4]])
        precondition(restored.songs(in: [reducedPlaylist, reducedPlaylist]).count == 1)
        precondition(restored.songs(in: []).isEmpty)
        print("PlaybackHistory tests passed.")
    }
}
