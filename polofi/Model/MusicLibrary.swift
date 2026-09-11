import Foundation

enum MusicLibrary {
    // Load once so every screen shares the same playlist and song identities.
    static let playlists: [Playlist] = {
        do {
            return try load()
        } catch {
            print("Unable to load music library: \(error.localizedDescription)")
            return []
        }
    }()

    static func load(bundle: Bundle = .main) throws -> [Playlist] {
        guard let url = bundle.url(forResource: "music", withExtension: "csv") else {
            throw LibraryError("music.csv is missing from the app bundle.")
        }
        let playlists = try parse(String(contentsOf: url, encoding: .utf8))
        return playlists.compactMap { playlist in
            let availableSongs = playlist.songs.filter { song in
                let exists = bundle.url(forResource: song.filename, withExtension: nil) != nil
                if !exists {
                    print("Skipping missing audio in \(playlist.name): \(song.filename)")
                }
                return exists
            }
            guard !availableSongs.isEmpty else { return nil }
            return Playlist(id: playlist.id, name: playlist.name, songs: availableSongs,
                            coverArt: playlist.coverArt, description: playlist.description)
        }
    }

    static func parse(_ csv: String) throws -> [Playlist] {
        let rows = try CSVReader.rows(from: csv)
        let headers = ["playlist", "coverArt", "title", "filename", "artist", "albumArt"]
        guard let header = rows.first, header == headers || header == headers + ["playlistDesc"] else {
            throw LibraryError("music.csv must begin with: \(headers.joined(separator: ",")), optionally followed by playlistDesc")
        }

        var names: [String] = []
        var covers: [String: String] = [:]
        var descriptions: [String: String] = [:]
        var songs: [String: [Song]] = [:]
        for (index, row) in rows.dropFirst().enumerated() {
            guard row.count == header.count else {
                throw LibraryError("CSV record \(index + 2) must contain \(header.count) fields.")
            }
            let name = row[0]
            let cover = row[1].isEmpty ? "Cover1" : row[1]
            if header.count == 7, !row[6].isEmpty {
                if let existing = descriptions[name], existing != row[6] {
                    throw LibraryError("Playlist \(name) has conflicting playlistDesc values.")
                }
                descriptions[name] = row[6]
            }
            guard !name.isEmpty, !row[2].isEmpty, !row[3].isEmpty else {
                throw LibraryError("CSV record \(index + 2) needs a playlist, title, and filename.")
            }
            if let existingCover = covers[name] {
                guard existingCover == cover else {
                    throw LibraryError("Playlist \(name) has conflicting coverArt values.")
                }
            } else {
                names.append(name)
                covers[name] = cover
            }
            guard !(songs[name] ?? []).contains(where: { $0.filename == row[3] }) else {
                throw LibraryError("Duplicate song in playlist \(name): \(row[3])")
            }
            songs[name, default: []].append(Song(
                title: row[2], filename: row[3],
                artist: row[4].isEmpty ? "Unknown Artist" : row[4],
                albumArt: row[5].isEmpty ? "AlbumArt" : row[5]
            ))
        }
        return names.map {
            Playlist(name: $0, songs: songs[$0] ?? [], coverArt: covers[$0] ?? "Cover1",
                     description: descriptions[$0] ?? "")
        }
    }
}

private struct LibraryError: LocalizedError {
    let message: String
    init(_ message: String) { self.message = message }
    var errorDescription: String? { message }
}

private enum CSVReader {
    // Supports spreadsheet exports: UTF-8 BOM, CRLF, quoted commas/newlines and escaped quotes.
    static func rows(from text: String) throws -> [[String]] {
        var input = text.replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
        if input.first == "\u{FEFF}" { input.removeFirst() }
        let header = input.prefix(while: { $0 != "\n" })
        let delimiter: Character = header.contains(";") ? ";" : ","
        var rows: [[String]] = []
        var row: [String] = []
        var field = ""
        var inQuotes = false
        var closedQuote = false
        var iterator = input.makeIterator()
        var current = iterator.next()

        func finishField() {
            row.append(field.trimmingCharacters(in: .whitespacesAndNewlines))
            field = ""
            closedQuote = false
        }
        func finishRow() {
            finishField()
            if row.contains(where: { !$0.isEmpty }) { rows.append(row) }
            row = []
        }

        while let character = current {
            if inQuotes {
                if character == "\"" {
                    current = iterator.next()
                    if current == "\"" {
                        field.append("\"")
                    } else {
                        inQuotes = false
                        closedQuote = true
                        continue
                    }
                } else {
                    field.append(character)
                }
            } else if character == delimiter {
                finishField()
            } else if character == "\n" {
                finishRow()
            } else if character == "\"", field.isEmpty, !closedQuote {
                inQuotes = true
            } else {
                guard !closedQuote, character != "\"" else {
                    throw LibraryError("Invalid quoting in CSV record \(rows.count + 1).")
                }
                field.append(character)
            }
            current = iterator.next()
        }
        guard !inQuotes else { throw LibraryError("Unclosed quoted field in music.csv.") }
        finishRow()
        return rows
    }
}
