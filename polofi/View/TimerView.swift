//
//  TimerView.swift
//  polofi
//
//  Created by Amelia Citra on 10/04/26.
//

import SwiftUI

struct TimerView: View {
    @StateObject private var viewModel: TimerViewModel
    @Environment(\.scenePhase) private var scenePhase
    @State private var scheduler = DayPhaseScheduler()

    init(playlist: Playlist, duration: TimeInterval) {
        _viewModel = StateObject(wrappedValue: TimerViewModel(playlist: playlist, duration: duration))
    }

    var body: some View {
        ZStack {
            SetBgView()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Focus Time:")
                            .font(.headline)

                        Text("\(viewModel.minutesRemaining) Minutes")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .minimumScaleFactor(0.75)

                        Text("\(viewModel.secondsRemainingPadded) Seconds")
                            .font(.headline)
                    }
                    .padding(.top, 8)

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 20)

                Spacer(minLength: 0)

                SongsPlay(viewModel: viewModel.songsViewModel)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 28)
            }
            .foregroundColor(scheduler.phase.textColor)
        }
        .onAppear {
            viewModel.startTimer()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                scheduler.refreshFromSystemClock()
            }
        }
    }
}

#Preview("Timer View") {
    TimerView(
        playlist: Playlist.mockData.first ?? Playlist(id: UUID(), name: "Sample", songs: []),
        duration: 125
    )
}
