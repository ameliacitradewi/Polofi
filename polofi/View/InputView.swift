//
//  InputView.swift
//  polofi
//
//  Created by Amelia Citra on 06/04/26.
//

import SwiftUI

struct InputView: View {
    @State private var selectedPlaylist: Playlist? = Playlist.mockData.first
    @State private var selectedHour = 0
    @State private var selectedMinute = 0
    
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack {
                    Color.yellow.ignoresSafeArea()
                    
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
//                                .frame(maxWidth: .infinity)
                                
                                Text(":")
                                
                                Picker("", selection: $selectedMinute) {
                                    ForEach(0..<60, id: \.self) { minute in
                                        Text(String(format: "%02d", minute)).tag(minute)
                                    }
                                }
                                .pickerStyle(.wheel)
//                                .frame(maxWidth: .infinity)
                            }
                        }
                        
                        Picker("Select Playlist", selection: $selectedPlaylist) {
                            ForEach(Playlist.mockData) { playlist in
                                Text(playlist.name)
                                    .tag(playlist as Playlist?)
                            }
                        }
                        
                        NavigationLink(destination: TimerView(playlist: selectedPlaylist!, duration: durationInSeconds)) {
                            Text("Start")
                        }
                    } // end vstack
                    .frame(width: geo.size.width * 0.8)
                } // end zstack
            } // end geometry
        }
    }
    
    private var durationInSeconds: TimeInterval {
        TimeInterval((selectedHour * 3600) + (selectedMinute * 60))
    }
    
}

#Preview {
    InputView()
}
