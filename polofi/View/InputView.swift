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
        NavigationStack {
            VStack {
                DatePicker(
                    "Set Focus Time",
                    selection: $selectedTime,
                    displayedComponents: [.hourAndMinute]
                )
                
                Picker("Select Playlist", selection: $selectedPlaylist) {
                    ForEach(Playlist.mockData) { playlist in
                        Text(playlist.name)
                            .tag(playlist as Playlist?)
                    }
                }
                
                NavigationLink(destination: TimerView(playlist: selectedPlaylist!, duration: durationInSeconds)) {
                    Text("Start")
                }
                
                
            }
        }
        
    }
    
    private var durationInSeconds: TimeInterval {
        let components = Calendar.current.dateComponents([.hour, .minute], from: selectedTime)
        
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        
        return TimeInterval((hours * 3600) + (minutes * 60))
    }
    
}

#Preview {
    InputView()
}
