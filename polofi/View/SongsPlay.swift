//
//  SongsPlay.swift
//  polofi
//
//  Created by Amelia Citra on 30/04/26.
//

import SwiftUI

struct SongsPlay: View {
    @StateObject private var viewModel: SongsPlayViewModel

    init(playlist: Playlist) {
        _viewModel = StateObject(wrappedValue: SongsPlayViewModel(playlist: playlist))
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(viewModel.playlist.name)
                .font(.title2)
                .bold()

            HStack(spacing: 16) {
                Button {
                    viewModel.playPreviousSong()
                } label: {
                    Image(systemName: "backward.fill")
                        .font(.title3)
                }
                .disabled(viewModel.currentSongIndex == 0 || viewModel.playlist.songs.isEmpty)

                Text(viewModel.currentSongTitle)
                    .font(.headline)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)

                Button {
                    viewModel.playNextSong()
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.title3)
                }
                .disabled(viewModel.playlist.songs.isEmpty)
            }
            .padding(.horizontal)
        }
        .onDisappear {
            viewModel.stop()
        }
    }
}

#Preview {
    SongsPlay(playlist: Playlist.mockData[0])
}
