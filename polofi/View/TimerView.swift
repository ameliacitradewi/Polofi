//
//  TimerView.swift
//  polofi
//
//  Created by Amelia Citra on 10/04/26.
//

import SwiftUI
import AVFoundation

struct TimerView: View {
    let playlist: Playlist
    let duration: TimeInterval

    @State private var remainingTime: TimeInterval
    @State private var audioPlayer: AVAudioPlayer?
    @State private var currentSongIndex: Int = 0
    
    private var timeString: String {
        let totalSeconds = max(Int(remainingTime), 0)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    init(playlist: Playlist, duration: TimeInterval) {
        self.playlist = playlist
        self.duration = duration
        _remainingTime = State(initialValue: duration)
    }

    var body: some View {
        VStack(spacing: 20) {
            
            Text("Now Playing")
                .font(.headline)
            
            Text(playlist.name)
                .font(.title)
                .bold()
            
            Text(timeString)
//            Text("\(Int(remainingTime)) seconds")
                .font(.largeTitle)
            
            SongsPlay(playlist: playlist)

        }
        .onAppear {
            startTimer()
        }
    }

    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                timer.invalidate()
            }
        }
    }
    
    private func playSong() {
        _ = playlist.songs
    }
}

