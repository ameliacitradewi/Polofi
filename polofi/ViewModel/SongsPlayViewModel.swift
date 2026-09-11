//
//  SongsPlayViewModel.swift
//  polofi
//
//  Created by Amelia Citra on 30/04/26.
//

import Foundation
import AVFoundation
import Combine

@MainActor
final class SongsPlayViewModel: NSObject, ObservableObject {
    @Published private(set) var currentSongIndex: Int = 0
    @Published private(set) var isPlaying: Bool = false

    private static let timerEndSoundFilename = "ding.mp3"

    @Published private(set) var playlist: Playlist
    private let history: PlaybackHistory
    private var audioPlayer: AVAudioPlayer?
    private var timerEndPlayer: AVAudioPlayer?
    private var suppressAutoAdvance = false

    var currentSong: Song? {
        guard playlist.songs.indices.contains(currentSongIndex) else { return nil }
        return playlist.songs[currentSongIndex]
    }

    var currentSongTitle: String {
        currentSong?.title ?? "No songs available"
    }
    
    var currentSongArtist: String {
        currentSong?.artist ?? "Unknown"
    }
    
    var displaySong: String {
        "\(currentSongArtist) - \(currentSongTitle)"
    }

    var currentTime: TimeInterval { audioPlayer?.currentTime ?? 0 }
    var duration: TimeInterval { audioPlayer?.duration ?? 0 }

    func seek(to time: TimeInterval) {
        guard time.isFinite, let audioPlayer else { return }
        audioPlayer.currentTime = min(max(time, 0), audioPlayer.duration)
        objectWillChange.send()
    }

    init(playlist: Playlist, history: PlaybackHistory? = nil) {
        self.playlist = playlist
        self.history = history ?? .shared
        super.init()
    }

    func play(_ playlist: Playlist, startingAt song: Song? = nil) {
        guard !playlist.songs.isEmpty else { return }
        let index: Int
        if let song {
            guard let match = playlist.songs.firstIndex(where: { $0.filename == song.filename }) else { return }
            index = match
        } else {
            index = 0
        }
        stop()
        audioPlayer = nil
        self.playlist = playlist
        currentSongIndex = index
        playCurrentSong()
    }

    func startPlaybackIfNeeded() {
        guard !playlist.songs.isEmpty else {
            isPlaying = false
            return
        }

        configureAudioSession()

        if let player = audioPlayer {
            if !player.isPlaying {
                suppressAutoAdvance = false
                isPlaying = player.play()
                if isPlaying, let currentSong { history.record(currentSong) }
            }
            return
        }

        playCurrentSong()
    }

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
    }

    func playNextSong() {
        guard !playlist.songs.isEmpty else { return }
        suppressAutoAdvance = false
        currentSongIndex = (currentSongIndex + 1) % playlist.songs.count
        playCurrentSong()
    }

    func playPreviousSong() {
        guard currentSongIndex > 0 else { return }
        suppressAutoAdvance = false
        currentSongIndex -= 1
        playCurrentSong()
    }

    func playCurrentSong() {
        guard !playlist.songs.isEmpty else {
            isPlaying = false
            return
        }

        configureAudioSession()
        suppressAutoAdvance = false
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false

        let song = playlist.songs[currentSongIndex]

        guard let url = audioURL(for: song.filename) else {
            isPlaying = false
            print("Audio file not found: \(song.filename)")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            isPlaying = audioPlayer?.play() == true
            if isPlaying { history.record(song) }
        } catch {
            isPlaying = false
            print("Failed to play audio: \(error.localizedDescription)")
        }
    }

    func stop() {
        suppressAutoAdvance = true
        audioPlayer?.stop()
        timerEndPlayer?.stop()
        isPlaying = false
    }

    func togglePlayback() {
        if isPlaying {
            audioPlayer?.pause()
            isPlaying = false
        } else {
            startPlaybackIfNeeded()
        }
    }

    func pauseWhenTimerEnds() {
        suppressAutoAdvance = true
        audioPlayer?.pause()
        isPlaying = false
        playTimerEndSound()
    }

    private func playTimerEndSound() {
        configureAudioSession()
        guard let url = audioURL(for: Self.timerEndSoundFilename) else {
            print("Timer end sound not found: \(Self.timerEndSoundFilename)")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = 0
            player.volume = 1
            player.prepareToPlay()
            timerEndPlayer = player
            if !player.play() {
                print("Failed to start timer end sound: \(Self.timerEndSoundFilename)")
            }
        } catch {
            print("Failed to play timer end sound: \(error.localizedDescription)")
        }
    }

    private func audioURL(for filename: String) -> URL? {
        if let url = Bundle.main.url(forResource: filename, withExtension: nil) {
            return url
        }

        let nsFilename = filename as NSString
        let fileNameWithoutExtension = nsFilename.deletingPathExtension
        let fileExtension = nsFilename.pathExtension
        let resolvedExtension = fileExtension.isEmpty ? nil : fileExtension

        return Bundle.main.url(forResource: fileNameWithoutExtension, withExtension: resolvedExtension)
    }
}

extension SongsPlayViewModel: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            guard flag, player === audioPlayer, !suppressAutoAdvance else { return }
            playNextSong()
        }
    }
}
