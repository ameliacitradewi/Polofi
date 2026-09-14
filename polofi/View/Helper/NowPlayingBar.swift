//
//  NowPlayingBar.swift
//  polofi
//
//  Created by Amelia Citra on 11/09/26.
//

import SwiftUI

struct NowPlayingBar: View {
    @ObservedObject var player: SongsPlayViewModel
    let onOpen: () -> Void

    @ViewBuilder
    var body: some View {
        if let selectedSong = player.currentSong {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(player.isPlaying ? "Now Playing:" : "Paused:")
                        .font(.subheadline)
                        .foregroundStyle(Color.primary.opacity(0.85))

                    Text("\(selectedSong.artist) - \(selectedSong.title)")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                }

                Spacer(minLength: 8)

                Button {
                    onOpen()
                } label: {
                    Image(systemName: "chevron.up")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color.primary.opacity(0.85))
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Open Now Playing")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 0)
            .padding(.top, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .background(.ultraThinMaterial)
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(Color.primary.opacity(0.22))
                    .frame(height: 1)
            }
        }
    }
}

#Preview("NowPlayingBar · Light", traits: .sizeThatFitsLayout) {
    Group {
        NowPlayingBar(
            player: SongsPlayViewModel(playlist: Playlist(
                name: "Study",
                songs: [Song(
                    title: "September Rain",
                    filename: "Hoffy Beats - September Rain (freetouse.com).mp3",
                    artist: "Hoffy Beats"
                )]
            )),
            onOpen: {}
        )
        .frame(width: 402)
        .background(Color(uiColor: .systemBackground))

    }
    .preferredColorScheme(.light)
}

#Preview("NowPlayingBar · Dark", traits: .sizeThatFitsLayout) {
    Group {
        NowPlayingBar(
            player: SongsPlayViewModel(playlist: Playlist(
                name: "Study",
                songs: [Song(
                    title: "September Rain",
                    filename: "Hoffy Beats - September Rain (freetouse.com).mp3",
                    artist: "Hoffy Beats"
                )]
            )),
            onOpen: {}
        )
        .frame(width: 402)
        .background(Color(uiColor: .systemBackground))

    }
    .preferredColorScheme(.dark)
}
