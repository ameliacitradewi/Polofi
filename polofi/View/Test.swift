//
//  Test.swift
//  polofi
//
//  Created by Amelia Citra on 14/05/26.
//

import SwiftUI

struct Test: View {
    let playlist: Playlist
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                SetBgView()
                
                VStack(alignment: .leading, spacing: 0) {
                        Text("Focus Time")
                            .font(.headline.bold())
                        
                        Text("22 Hour")
                            .font(.largeTitle.bold())
                        
                        Text("55 Minutes ")
                            .font(.title.bold())
                        + Text("23 Seconds")
                            .font(.title3).bold()
                    
                    Spacer()
                    
                    SongsPlayHost(playlist: playlist)
                        .frame(maxWidth: geo.size.width)
                }
                .frame(maxWidth: geo.size.width)
                .foregroundColor(.white)
            }
        }
        
    }
    
}

#Preview {
    if let sample = Playlist.mockData.first {
        Test(playlist: sample)
    } else {
        // Fallback to a minimal inline mock if mockData is empty
        let fallback = Playlist(
            id: UUID(),
            name: "Sample",
            songs: []
        )
        Test(playlist: fallback)
    }
}
