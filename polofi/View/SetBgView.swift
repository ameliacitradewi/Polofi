//
//  BgView.swift
//  polofi
//
//  Created by Amelia Citra on 13/05/26.
//

// background that change based on the local time (see DayPhase)

import SwiftUI

struct SetBgView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var scheduler = DayPhaseScheduler() // from DayPhase.swift
    
    var body: some View {
        Image(scheduler.phase.imageName)
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    scheduler.refreshFromSystemClock()
                }
            }
    }
}
