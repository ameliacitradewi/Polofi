//
//  SongsPlay.swift
//  polofi
//
//  Created by Amelia Citra on 30/04/26.
//

import SwiftUI

struct SongsPlay: View {
    @ObservedObject var viewModel: SongsPlayViewModel
    @State private var isControlsVisible = true

    init(viewModel: SongsPlayViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                Text(viewModel.playlist.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)
                    .lineLimit(1)

                Spacer(minLength: 8)

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isControlsVisible.toggle()
                    }
                } label: {
                    Image(systemName: isControlsVisible ? "chevron.up" : "chevron.down")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.black)
                        .frame(width: 32, height: 32)
                        .background {
                            Circle()
                                .fill(Color.primary.opacity(0.1))
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isControlsVisible ? "Hide playback controls" : "Show playback controls")
            }

            if isControlsVisible {
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

                    MarqueeView(text: viewModel.currentSongTitle, font: .headline)
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
                .foregroundColor(.black)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.94))
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
        }
        .onAppear {
            viewModel.startPlaybackIfNeeded()
        }
        .onDisappear {
            viewModel.stop()
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

#Preview {
    SongsPlayHost(playlist: Playlist.mockData[0])
        .padding()
        .background(Color.gray.opacity(0.3))
}
