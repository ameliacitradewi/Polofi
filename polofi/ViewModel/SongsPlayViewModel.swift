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

    let playlist: Playlist
    private var audioPlayer: AVAudioPlayer?
    private var timerEndPlayer: AVAudioPlayer?
    private var suppressAutoAdvance = false

    var currentSongTitle: String {
        guard !playlist.songs.isEmpty else { return "No songs available" }
        return playlist.songs[currentSongIndex].title
    }

    init(playlist: Playlist) {
        self.playlist = playlist
        super.init()
    }

    func startPlaybackIfNeeded() {
        guard !playlist.songs.isEmpty else {
            isPlaying = false
            return
        }

        configureAudioSession()

        if let player = audioPlayer {
            if !player.isPlaying {
                player.play()
                isPlaying = true
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
            audioPlayer?.play()
            isPlaying = true
        } catch {
            isPlaying = false
            print("Failed to play audio: \(error.localizedDescription)")
        }
    }

    func stop() {
        audioPlayer?.stop()
        timerEndPlayer?.stop()
        isPlaying = false
    }

    func pauseWhenTimerEnds() {
        suppressAutoAdvance = true
        audioPlayer?.pause()
        isPlaying = false
        playTimerEndSound()
    }

    private func playTimerEndSound() {
        guard let url = audioURL(for: Self.timerEndSoundFilename) else {
            print("Timer end sound not found: \(Self.timerEndSoundFilename)")
            return
        }

        do {
            timerEndPlayer = try AVAudioPlayer(contentsOf: url)
            timerEndPlayer?.prepareToPlay()
            timerEndPlayer?.play()
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
            guard !suppressAutoAdvance else { return }
            playNextSong()
        }
    }
}
