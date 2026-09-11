import Foundation

@main
struct MusicLibraryTests {
    @MainActor
    static func main() throws {
        let header = "playlist,coverArt,title,filename,artist,albumArt\n"
        let csv = try String(contentsOfFile: "polofi/Resources/music.csv", encoding: .utf8)
        let playlists = try MusicLibrary.parse(csv)
        precondition(!playlists.isEmpty)
        let audioFiles = Set(try FileManager.default.subpathsOfDirectory(atPath: "polofi/Resources/Songs")
            .map { ($0 as NSString).lastPathComponent })
        for song in playlists.flatMap(\.songs) {
            precondition(audioFiles.contains(song.filename), "Missing audio: \(song.filename)")
        }

        // Fixed fixtures keep parser tests independent of the editable music catalog.
        let fixture = header + "Calm,Cover1,First,first.mp3,Artist,AlbumArt\n"
        let expanded = try MusicLibrary.parse(fixture + "Calm,Cover1,New Track,new.mp3,Artist,AlbumArt\nFocus,Cover1,Focus Track,focus.mp3,Artist,AlbumArt\n")
        precondition(expanded.count == 2 && expanded[0].songs.count == 2)
        precondition(expanded.last?.name == "Focus")
        let semicolon = try MusicLibrary.parse("\u{FEFF}" + header.replacingOccurrences(of: ",", with: ";")
            + "Calm;Cover1;\"Rain; Again, Tonight\";rain.mp3;Artist;AlbumArt\r\n")
        precondition(semicolon[0].songs[0].title == "Rain; Again, Tonight")

        let descriptionHeader = "playlist;coverArt;title;filename;artist;albumArt;playlistDesc\n"
        let described = try MusicLibrary.parse(descriptionHeader
            + "Study;StudyCover;First;first.mp3;Artist;AlbumArt;\n"
            + "Study;StudyCover;Second;second.mp3;Artist;AlbumArt;\"Focus; steady rhythms.\"\n")
        precondition(described[0].description == "Focus; steady rhythms.")
        precondition(expanded[0].description.isEmpty)

        let quoted = try MusicLibrary.parse("\u{FEFF}" + header.replacingOccurrences(of: "\n", with: "\r\n") + "\r\nCalm,,\"Rain, \"\"Again\"\"\r\nTonight\",rain.mp3,,\r\n")
        precondition(quoted[0].songs[0].title == "Rain, \"Again\"\nTonight")
        precondition(quoted[0].coverArt == "Cover1")
        precondition(quoted[0].songs[0].artist == "Unknown Artist")
        precondition(quoted[0].songs[0].albumArt == "AlbumArt")

        let shared = try MusicLibrary.parse(header + "Calm,,Track,same.mp3,,\nStudy,,Track,same.mp3,,")
        precondition(shared.count == 2)
        precondition(shared[0].songs[0].id != shared[1].songs[0].id)
        let empty = try MusicLibrary.parse(header)
        precondition(empty.isEmpty)

        for invalid in [
            "",
            "wrong,header\n",
            header + "Calm,Track,missing-columns.mp3\n",
            header + "Calm,,,track.mp3,,\n",
            header + "Calm,,Track,,,\n",
            header + ",,Track,track.mp3,,\n",
            header + "Calm,,\"Unclosed,track.mp3,,\n",
            header + "Calm,,\"Track\"extra,track.mp3,,\n",
            header + "Calm,,Tr\"ack,track.mp3,,\n",
            header + "Calm,,Track,same.mp3,,\nCalm,,Track,same.mp3,,\n",
            header + "Calm,Cover1,First,first.mp3,,\nCalm,Cover2,Second,second.mp3,,\n",
            descriptionHeader + "Study;;First;first.mp3;;;First description\nStudy;;Second;second.mp3;;;Different description\n",
        ] {
            do {
                _ = try MusicLibrary.parse(invalid)
                fatalError("Expected invalid CSV to fail: \(invalid)")
            } catch {
                precondition(!error.localizedDescription.isEmpty)
            }
        }

        // One missing audio file must not hide playlists with available songs.
        let temporaryBundle = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".bundle")
        try FileManager.default.createDirectory(at: temporaryBundle, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: temporaryBundle) }
        try (header + "Calm,,Available,available.mp3,,\nCalm,,Missing,missing.mp3,,\nEmpty,,Missing,missing.mp3,,\n")
            .write(to: temporaryBundle.appendingPathComponent("music.csv"), atomically: true, encoding: .utf8)
        try Data().write(to: temporaryBundle.appendingPathComponent("available.mp3"))
        let partial = try MusicLibrary.load(bundle: Bundle(url: temporaryBundle)!)
        precondition(partial.map(\.name) == ["Calm"])
        precondition(partial[0].songs.map(\.filename) == ["available.mp3"])

        if let path = CommandLine.arguments.dropFirst().first {
            guard let bundle = Bundle(path: path) else { fatalError("Invalid app bundle: \(path)") }
            let bundled = try MusicLibrary.load(bundle: bundle)
            precondition(bundled.map(\.name) == playlists.map(\.name))
            precondition(bundled.map(\.description) == playlists.map(\.description))
            precondition(bundled.flatMap(\.songs).map(\.filename) == playlists.flatMap(\.songs).map(\.filename))
            print("App bundle: CSV and all audio files verified.")
        }
        print("MusicLibrary tests passed.")
    }
}
