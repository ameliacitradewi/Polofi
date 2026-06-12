//
//  InputView.swift
//  polofi
//
//  Created by Amelia Citra on 06/04/26.
//

import SwiftUI

struct InputView: View {
    @State private var selectedPlaylist: Playlist? = Playlist.mockData.first
    @State private var selectedHour = 2
    @State private var selectedMinute = 5
    @State private var focusSession: FocusSession?

    var body: some View {
        GeometryReader { geo in
            ZStack {
                SetBgView()

                VStack {
                    Text("Set Focus Time")
                        .font(.headline)

                    VStack {
                        HStack {
                            Text("Hour")
                                .frame(maxWidth: .infinity)

                            Text("Min")
                                .frame(maxWidth: .infinity)
                        }

                        HStack {
                            Picker("", selection: $selectedHour) {
                                ForEach(0..<24, id: \.self) { hour in
                                    Text(String(format: "%02d", hour)).tag(hour)
                                }
                            }
                            .pickerStyle(.wheel)

                            Text(":")

                            Picker("", selection: $selectedMinute) {
                                ForEach(0..<60, id: \.self) { minute in
                                    Text(String(format: "%02d", minute)).tag(minute)
                                }
                            }
                            .pickerStyle(.wheel)
                        }
                    }

                    Picker("Select Playlist", selection: $selectedPlaylist) {
                        ForEach(Playlist.mockData) { playlist in
                            Text(playlist.name)
                                .tag(playlist as Playlist?)
                        }
                    }

                    Button("Start") {
                        guard let selectedPlaylist, durationInSeconds > 0 else { return }
                        focusSession = FocusSession(playlist: selectedPlaylist, duration: durationInSeconds)
                    }
                    .disabled(selectedPlaylist == nil || durationInSeconds == 0)
                }
                .padding()
                .frame(width: geo.size.width * 0.8)
                .background(Color.white.opacity(0.95)).cornerRadius(30)
            }
        }
        .navigationDestination(item: $focusSession) { session in
            TimerView(playlist: session.playlist, duration: session.duration)
        }
    }

    private var durationInSeconds: TimeInterval {
        TimeInterval((selectedHour * 3600) + (selectedMinute * 60))
    }
}

private struct FocusSession: Identifiable, Hashable {
    let id = UUID()
    let playlist: Playlist
    let duration: TimeInterval
}

#Preview {
    NavigationStack {
        InputView()
    }
}
