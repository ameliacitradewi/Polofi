//
//  InputView.swift
//  polofi
//
//  Created by Amelia Citra on 06/04/26.
//

import SwiftUI

struct InputView: View {
    @State private var selectedPlaylist: Playlist? = Playlist.mockData.first
    @State private var timeInterval: TimeInterval = 0
    @State private var selectedTime: Date = Date()
    
    
    var body: some View {
        VStack {
            DatePicker(
                "Select Time",
                selection: $selectedTime,
                displayedComponents: [.hourAndMinute]
            )
            
            Picker("Select Playlist", selection: $selectedPlaylist) {
                ForEach(Playlist.mockData) { playlist in
                    Text(playlist.name)
                        .tag(playlist as Playlist?)
                }
            }
            
            Button("Start") {
                print(selectedPlaylist?.name ?? "No playlist")
            }
        }
        
    }
}

#Preview {
    InputView()
}
