//
//  TimerViewModel.swift
//  polofi
//
//  Created by Amelia Citra on 14/05/26.
//

import Foundation
import Combine

@MainActor
final class TimerViewModel: ObservableObject {
    let playlist: Playlist
    let duration: TimeInterval

    @Published private(set) var remainingTime: TimeInterval

    private var countdownTimer: Timer?

    init(playlist: Playlist, duration: TimeInterval) {
        self.playlist = playlist
        self.duration = duration
        self.remainingTime = duration
    }

    var formattedTime: String {
        let totalSeconds = max(Int(remainingTime), 0)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    /// Untuk tampilan baris “X Minutes” / “YY Seconds”.
    /// 
    var minutesRemaining: Int {
        max(Int(remainingTime), 0) / 60
    }

    var secondsRemaining: Int {
        max(Int(remainingTime), 0) % 60
    }

    var secondsRemainingPadded: String {
        String(format: "%02d", secondsRemaining)
    }

    func startTimer() {
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self else {
                timer.invalidate()
                return
            }
            Task { @MainActor in
                self.handleCountdownTick()
            }
        }
    }

    private func handleCountdownTick() {
        if remainingTime > 0 {
            remainingTime -= 1
        } else {
            countdownTimer?.invalidate()
            countdownTimer = nil
        }
    }
}
