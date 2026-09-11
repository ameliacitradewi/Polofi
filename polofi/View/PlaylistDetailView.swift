//
//  PlaylistDetailView.swift
//  polofi
//
//  Created by Amelia Citra on 11/09/26.
//

import SwiftUI
import AVFoundation

struct PlaylistDetailView: View {
    let playlist: Playlist
    @ObservedObject var player: SongsPlayViewModel
    @State private var showsNowPlaying = false
    @State private var totalDuration: TimeInterval?

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 10) {
                        Image.musicArtwork(named: playlist.coverArt)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: min(geometry.size.width * 0.95, 430))
//                            .overlay {
//                                LinearGradient(colors: [.black.opacity(0.4), .clear],
//                                               startPoint: .top, endPoint: .center)
//                            }
                            .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 32, bottomTrailingRadius: 32))
                            .accessibilityLabel("Cover for \(playlist.name)")

                        VStack(alignment: .leading, spacing: 20) {
                            playlistInformation

                            LazyVStack(spacing: 12) {
                                ForEach(playlist.songs) { song in
                                    songRow(song)
                                }
                            }

                            if playlist.songs.isEmpty {
                                ContentUnavailableView("No songs available", systemImage: "music.note")
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                    }
                }
                .ignoresSafeArea(.container, edges: .top)
            }
        }
        .background(Color.black)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            NowPlayingBar(player: player) {
                showsNowPlaying = true
            }
        }
        .navigationTitle("\(playlist.name) Playlist")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .preferredColorScheme(.dark)
        .tint(.white)
        .navigationDestination(isPresented: $showsNowPlaying) {
            NowPlayingView(player: player)
        }
        .task(id: playlist.id) {
            await loadTotalDuration()
        }
    }

    private var playlistInformation: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(playlist.name)
                .font(.title2.bold())
                .foregroundStyle(.white)

            if !playlist.description.isEmpty {
                Text(playlist.description)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
            }

            Text(totalDuration.map {
                "\(playlist.songs.count) songs · \(Int(ceil($0 / 60))) minutes"
            } ?? "\(playlist.songs.count) songs")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.45))
        }
    }

    private func songRow(_ song: Song) -> some View {
        Button {
            player.play(playlist, startingAt: song)
        } label: {
            HStack(spacing: 12) {
                Image.musicArtwork(named: song.albumArt)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 5))

                VStack(alignment: .leading, spacing: 3) {
                    Text(song.title)
                        .font(.body)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(song.artist)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.45))
                        .lineLimit(1)
                }

                Spacer(minLength: 12)

                if player.isPlaying && player.currentSong?.filename == song.filename {
                    Image(systemName: "waveform")
                        .font(.body)
                        .foregroundStyle(.white)
                        .accessibilityLabel("Now playing")
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }


    private func loadTotalDuration() async {
        var total: TimeInterval = 0
        for song in playlist.songs {
            guard !Task.isCancelled else { return }
            if song.duration > 0 {
                total += song.duration
            } else {
                guard let url = Bundle.main.url(forResource: song.filename, withExtension: nil) else { return }
                do {
                    let duration = try await AVURLAsset(url: url).load(.duration).seconds
                    guard duration.isFinite, duration >= 0 else { return }
                    total += duration
                } catch {
                    return
                }
            }
        }
        guard !Task.isCancelled else { return }
        totalDuration = total
    }
}

#Preview {
    if let playlist = MusicLibrary.playlists.first {
        NavigationStack {
            PlaylistDetailView(playlist: playlist, player: SongsPlayViewModel(playlist: playlist))
        }
    }
}
