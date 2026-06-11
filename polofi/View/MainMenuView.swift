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
                LinearGradient(colors: [Color.color1, Color.color2], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack (spacing: 20) {
                    VStack(alignment: .trailing) {
                        Text("Focus Timer")
                            .font(.largeTitle.bold())

                        Text("""
                            Stay locked in. Work in focused sprints,
                            rest with intention, and watch your productivity compound.
                            """)
                        .fontWeight(.semibold)

                        Spacer()
                    }
                    .padding(.top, 30)
                    .padding(.horizontal, 16)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .frame(height: geo.size.height * 0.7)
                    .background(alignment: .leading) {
                        Image("clock2")
                            .resizable()
                            .scaledToFill()
                    }
                    .clipShape(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                    )
//                    .overlay {
//                        RoundedRectangle(cornerRadius: 28, style: .continuous)
//                            .stroke(Color.white.opacity(0.35), lineWidth: 1.5)
//                    }
                    .shadow(
                        color: Color.black.opacity(0.25),
                        radius: 4,
                        x: 0,
                        y: 4
                    )
                    
                    
                    VStack(alignment: .trailing) {
                        Text("Music Player")
                            .font(.largeTitle.bold())

                        Text("""
                            Pre loaded lo-fi tracks,
                            ready to play.
                            """)
                        .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 16)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .bottomTrailing)
                    .frame(height: geo.size.height * 0.2)
                    .background(alignment: .leading) {
                        Image("headphone")
                            .resizable()
                            .scaledToFill()
                    }
                    .clipShape(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                    )
//                    .overlay {
//                        RoundedRectangle(cornerRadius: 28, style: .continuous)
//                            .stroke(Color.white.opacity(0.35), lineWidth: 1.5)
//                    }
                    .shadow(
                        color: Color.black.opacity(0.25),
                        radius: 4,
                        x: 0,
                        y: 4
                    )
                    
                }
                .foregroundColor(Color.white)
                .padding(.vertical, 10)
                .padding(.horizontal, 10)
                .frame(width: .infinity, height: geo.size.height)
            }
        }
    }
}


#Preview {
    MainMenuView()
}
