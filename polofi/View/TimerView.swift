//
//  TimerView.swift
//  polofi
//
//  Created by Amelia Citra on 10/04/26.
//

import SwiftUI

struct TimerView: View {
    @StateObject private var viewModel: TimerViewModel

    init(playlist: Playlist, duration: TimeInterval) {
        _viewModel = StateObject(wrappedValue: TimerViewModel(playlist: playlist, duration: duration))
    }

    var body: some View {
        VStack(spacing: 20) {

            Text("Now Playing")
                .font(.headline)

            Text(viewModel.playlist.name)
                .font(.title)
                .bold()

            Text(viewModel.formattedTime)
                .font(.largeTitle)

            SongsPlay(playlist: viewModel.playlist)

        }
        .onAppear {
            viewModel.startTimer()
        }
    }
}

#Preview("Timer View") {
    TimerView(
        playlist: Playlist.mockData.first ?? Playlist(id: UUID(), name: "Sample", songs: []),
        duration: 125
    )
    .padding()
}
