//
//  SongsPlay.swift
//  polofi
//
//  Created by Amelia Citra on 30/04/26.
//

import SwiftUI

struct SongsPlay: View {
    @ObservedObject var viewModel: SongsPlayViewModel
    @State private var showsPlaylists = false
    @State private var hasStartedPlayback = false

    init(viewModel: SongsPlayViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(alignment: .center, spacing: 12) {
                Text(viewModel.playlist.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Spacer(minLength: 8)

                Button {
                    showsPlaylists = true
                } label: {
                    Image(systemName: "chevron.up")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 32, height: 32)
                        .background {
                            Circle()
                                .fill(Color.primary.opacity(0.1))
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open Playlists")
            }

            HStack(alignment: .center, spacing: 0) {
                Button {
                    viewModel.playPreviousSong()
                } label: {
                    Image(systemName: "backward.fill")
                        .font(.title3)
                        .frame(minWidth: 44, minHeight: 44)
                        .contentShape(Rectangle())
                }
                .disabled(viewModel.currentSongIndex == 0 || viewModel.playlist.songs.isEmpty)

                MarqueeView(text: viewModel.displaySong, font: .headline)
                    .frame(minWidth: 0, maxWidth: .infinity)

                Button {
                    viewModel.playNextSong()
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.title3)
                        .frame(minWidth: 44, minHeight: 44)
                        .contentShape(Rectangle())
                }
                .disabled(viewModel.playlist.songs.isEmpty)
            }
            .foregroundColor(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(uiColor: .secondarySystemBackground).opacity(0.94))
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
        }
        .onAppear {
            if !hasStartedPlayback {
                viewModel.startPlaybackIfNeeded()
                hasStartedPlayback = true
            }
        }
        .onDisappear {
            if !showsPlaylists {
                viewModel.stop()
                hasStartedPlayback = false
            }
        }
        .navigationDestination(isPresented: $showsPlaylists) {
            PlaylistView(player: viewModel)
        }
    }
}

/// Memiliki lifecycle ViewModel sendiri — untuk preview / layar tanpa parent yang share VM.
struct SongsPlayHost: View {
    @StateObject private var viewModel: SongsPlayViewModel

    init(playlist: Playlist) {
        _viewModel = StateObject(wrappedValue: SongsPlayViewModel(playlist: playlist))
    }

    var body: some View {
        SongsPlay(viewModel: viewModel)
    }
}

#Preview("SongsPlay · Light") {
    Group {
        NavigationStack {
            if let playlist = MusicLibrary.playlists.first {
                SongsPlayHost(playlist: playlist)
                    .padding()
                    .background(Color.gray.opacity(0.3))
            }
        }
    }
    .preferredColorScheme(.light)
}

#Preview("SongsPlay · Dark") {
    Group {
        NavigationStack {
            if let playlist = MusicLibrary.playlists.first {
                SongsPlayHost(playlist: playlist)
                    .padding()
                    .background(Color.gray.opacity(0.3))
            }
        }
    }
    .preferredColorScheme(.dark)
}
