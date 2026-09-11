//
//  NowPlayingView.swift
//  polofi
//
//  Created by Amelia Citra on 11/09/26.
//

import SwiftUI

struct NowPlayingView: View {
    @ObservedObject var player: SongsPlayViewModel
    @State private var scrubFraction: Double?

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                if let song = player.currentSong {
                    VStack(spacing: 0) {
                        artwork(song, width: min(geometry.size.width, 540))
                            .frame(height: max(240, geometry.size.height * 0.60))

                        VStack(alignment: .leading, spacing: 26) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(song.title)
                                    .font(.title2.bold())
                                    .foregroundStyle(.white)
                                    .fixedSize(horizontal: false, vertical: true)
                                Text(song.artist)
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.45))
                            }

                            playbackProgress
                            playbackControls
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                    .frame(maxWidth: 540)
                    .frame(maxWidth: .infinity)
                } else {
                    ContentUnavailableView("No song playing", systemImage: "music.note")
                        .frame(minHeight: geometry.size.height)
                }
            }
        }
        .background(.black)
        .navigationTitle("Now Playing")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .preferredColorScheme(.dark)
        .tint(.white)
        .onChange(of: player.currentSong?.id) { _, _ in scrubFraction = nil }
    }

    private func artwork(_ song: Song, width: CGFloat) -> some View {
        ZStack {
            Image.musicArtwork(named: song.albumArt)
                .resizable()
                .scaledToFill()
                .frame(width: width * 0.85, height: width * 0.85)
                .clipped()
                .blur(radius: 55)
                .opacity(0.65)

            Image.musicArtwork(named: song.albumArt)
                .resizable()
                .scaledToFill()
                .frame(width: width * 0.52, height: width * 0.52)
                .clipped()
                .accessibilityLabel("Album art for \(song.title)")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Album art for \(song.title)")
    }

    private var playbackProgress: some View {
        TimelineView(.animation(minimumInterval: 0.25, paused: !player.isPlaying)) { _ in
            let duration = player.duration
            let elapsed = scrubFraction.map { $0 * duration } ?? player.currentTime
            let progress = duration > 0 ? elapsed / duration : 0

            VStack(spacing: 8) {
                GeometryReader { geometry in
                    WaveformProgress(progress: progress)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    guard duration > 0, geometry.size.width > 0 else { return }
                                    scrubFraction = min(max(value.location.x / geometry.size.width, 0), 1)
                                }
                                .onEnded { _ in
                                    if let scrubFraction { player.seek(to: scrubFraction * duration) }
                                    scrubFraction = nil
                                }
                        )
                }
                .frame(height: 64)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Playback position")
                .accessibilityValue("\(Self.timeLabel(elapsed)) of \(Self.timeLabel(duration))")
                .accessibilityAdjustableAction { direction in
                    switch direction {
                    case .increment: player.seek(to: player.currentTime + 10)
                    case .decrement: player.seek(to: player.currentTime - 10)
                    @unknown default: break
                    }
                }

                HStack {
                    Text(Self.timeLabel(elapsed))
                    Spacer()
                    Text(Self.timeLabel(duration))
                }
                .font(.footnote.monospacedDigit())
                .foregroundStyle(.white.opacity(0.75))
                .accessibilityHidden(true)
            }
        }
    }

    private var playbackControls: some View {
        HStack {
            Button { player.playPreviousSong() } label: {
                Image(systemName: "backward.end.fill")
                    .font(.system(size: 25))
                    .frame(width: 56, height: 56)
            }
            .disabled(player.currentSongIndex == 0)
            .accessibilityLabel("Previous song")

            Spacer()

            Button { player.togglePlayback() } label: {
                Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.black.opacity(0.75))
                    .frame(width: 88, height: 88)
                    .background {
                        Circle().fill(LinearGradient(
                            colors: [.white, Color(white: 0.78)],
                            startPoint: .top, endPoint: .bottom
                        ))
                    }
            }
            .accessibilityLabel(player.isPlaying ? "Pause" : "Play")

            Spacer()

            Button { player.playNextSong() } label: {
                Image(systemName: "forward.end.fill")
                    .font(.system(size: 25))
                    .frame(width: 56, height: 56)
            }
            .accessibilityLabel("Next song")
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
        .padding(.horizontal, 40)
    }

    private static func timeLabel(_ time: TimeInterval) -> String {
        let seconds = time.isFinite ? Int(max(0, time)) : 0
        return String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}

// Stylized waveform for the seek control; its highlighted portion tracks real playback time.
private struct WaveformProgress: View {
    let progress: Double

    var body: some View {
        Canvas { context, size in
            let count = max(1, Int(size.width / 6))
            let step = size.width / CGFloat(count)
            var bars = Path()
            for index in 0..<count {
                let variation = abs(sin(Double(index) * 1.73) * cos(Double(index) * 0.37))
                let height = size.height * (0.16 + 0.84 * variation)
                let rect = CGRect(x: CGFloat(index) * step, y: (size.height - height) / 2,
                                  width: max(2, step * 0.48), height: height)
                bars.addRoundedRect(in: rect, cornerSize: CGSize(width: 2, height: 2))
            }
            context.fill(bars, with: .color(.white.opacity(0.16)))
            context.clip(to: Path(CGRect(x: 0, y: 0, width: size.width * min(max(progress, 0), 1), height: size.height)))
            context.fill(bars, with: .color(.white))
        }
    }
}

#Preview {
    NavigationStack {
        NowPlayingView(player: SongsPlayViewModel(
            playlist: MusicLibrary.playlists.first ?? Playlist(name: "", songs: [])
        ))
    }
}
