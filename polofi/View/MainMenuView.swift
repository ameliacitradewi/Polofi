//
//  MainMenuView.swift
//  polofi
//
//  Created by Amelia Citra on 11/06/26.
//

import SwiftUI

struct MainMenuView: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // background
                
                VStack {
                    VStack (alignment: .trailing) {
                        Text("Focus Timer")
                            .font(.largeTitle.bold())
                        
                        Text("""
                            Stay locked in. Work in focused sprints,
                            rest with intention, and watch your productivity compound.
                            """)
                        
                        Spacer()
                    }
                    .padding(.top, 30)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity)
                    .frame(height: geo.size.height * 0.7)
                    .background(alignment: .leading) {
                        Image("clock2")
                            .resizable()
                            .scaledToFit()
                    }
                    .clipped()
                    
                    VStack (alignment: .trailing) {
                        Text("Music Player")
                            .font(.largeTitle.bold())
                        
                        Text("""
                            Pre loaded lo-fi tracks,
                            ready to play.
                            """)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: geo.size.height * 0.3)
                    .background(alignment: .leading) {
                        Image("headphone")
                            .resizable()
                            .scaledToFit()
                    }
                    .clipped()
                    
                }
                .frame(width: .infinity, height: geo.size.height)
            }
            .padding(.horizontal, 10)
        }
    }
}


#Preview {
    MainMenuView()
}
