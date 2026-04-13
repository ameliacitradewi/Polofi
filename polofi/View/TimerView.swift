//
//  TimerView.swift
//  polofi
//
//  Created by Amelia Citra on 10/04/26.
//

import SwiftUI

struct TimerView: View {
    let playlist: Playlist
    let duration: TimeInterval

    @State private var remainingTime: TimeInterval
    
    private var timeString: String {
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
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
}

