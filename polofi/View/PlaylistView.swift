//
//  PlaylistView.swift
//  polofi
//
//  Created by Amelia Citra on 13/05/26.
//

import SwiftUI

struct PlaylistView: View {
    private let playlists = MusicLibrary.playlists
    private let columns = [
        GridItem(.flexible(minimum: 0), spacing: 12),
        GridItem(.flexible(minimum: 0), spacing: 12),
    ]

    @ObservedObject private var history = PlaybackHistory.shared
    @StateObject private var player: SongsPlayViewModel
    @State private var showsNowPlaying = false
    @State private var selectedPlaylist: Playlist?
    private let ownsPlayback: Bool

    init(player: SongsPlayViewModel? = nil) {
        ownsPlayback = player == nil
        _player = StateObject(wrappedValue: player ?? SongsPlayViewModel(playlist: Playlist(name: "", songs: [])))
    }

    private var recentlyPlayedSongs: [Song] {
        history.songs(in: playlists)
    }

    var body: some View {
        ZStack {
            SetBgView()

            Color.black.opacity(0.18)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    if playlists.isEmpty {
                        ContentUnavailableView("No playlists available", systemImage: "music.note.list")
                    }
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(playlists) { playlist in
                            playlistCard(playlist)
                        }
                    }

                    if !recentlyPlayedSongs.isEmpty {
                        recentlyPlayedSection
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 40)
                .padding(.bottom, 20)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            nowPlayingBar
        }
        .navigationTitle("Playlists")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .navigationDestination(isPresented: $showsNowPlaying) {
            NowPlayingView(player: player)
        }
        .navigationDestination(item: $selectedPlaylist) { playlist in
            PlaylistDetailView(playlist: playlist, player: player)
        }
        .onDisappear {
            if ownsPlayback && !showsNowPlaying && selectedPlaylist == nil { player.stop() }
        }
    }

    private func playlistCard(_ playlist: Playlist) -> some View {
        Button {
            select(playlist)
        } label: {
            Color.clear
                .aspectRatio(4 / 3, contentMode: .fit)
                .overlay {
                    Image.musicArtwork(named: playlist.coverArt)
                        .resizable()
                        .scaledToFill()
                }
                .overlay {
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.85)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                }
                .overlay(alignment: .bottomLeading) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(playlist.name)
                            .font(.title3.bold())
                            .lineLimit(1)

                        Text("\(playlist.songs.count) songs")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay {
                    if player.playlist.id == playlist.id {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.white.opacity(0.85), lineWidth: 2)
                    }
                }
                .shadow(color: .black.opacity(0.28), radius: 7, y: 4)
                .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(playlist.name), \(playlist.songs.count) songs")
    }

    private var recentlyPlayedSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Recently Played")
                .font(.title3.weight(.medium))
                .foregroundStyle(.white.opacity(0.78))

            ForEach(recentlyPlayedSongs) { song in
                Button {
                    if let playlist = playlists.first(where: { $0.songs.contains(song) }) {
                        player.play(playlist, startingAt: song)
                    }
                } label: {
                    songRow(song)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
    }

    private func songRow(_ song: Song) -> some View {
        HStack(spacing: 12) {
            Image.musicArtwork(named: song.albumArt)
                .resizable()
                .scaledToFill()
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(song.title)
                    .font(.headline)
                    .lineLimit(1)

                Text(song.artist)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            if player.isPlaying && player.currentSong?.filename == song.filename {
                Image(systemName: "waveform")
                    .font(.title3.weight(.medium))
                    .accessibilityLabel("Now playing")
            }
        }
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var nowPlayingBar: some View {
        if let selectedSong = player.currentSong {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(player.isPlaying ? "Now Playing:" : "Paused:")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))

                    Text("\(selectedSong.artist) - \(selectedSong.title)")
                        .font(.headline)
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                Button {
                    showsNowPlaying = true
                } label: {
                    Image(systemName: "chevron.up")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white.opacity(0.85))
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Open Now Playing")
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 17)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial)
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(Color.white.opacity(0.22))
                    .frame(height: 1)
            }
        }
    }

    private func select(_ playlist: Playlist) {
        selectedPlaylist = playlist
    }
}

#Preview {
    NavigationStack {
        PlaylistView()
    }
}
