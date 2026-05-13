//
//  BgChange.swift
//  polofi
//
//  Created by Amelia Citra on 13/05/26.
//

import SwiftUI

enum DayPhase: String, CaseIterable {
    case morning, afternoon, evening, night
    
    var imageName: String { rawValue }
    
    // set time for enum
    static func phase(for date: Date, calendar: Calendar = .current) -> DayPhase {
        let comps = calendar.dateComponents([.hour, .minute], from: date)
        let hour = comps.hour ?? 0
        let minute = comps.minute ?? 0
        let minutes = hour * 60 + minute
        
        switch minutes {
        case 300...719: return .morning // 05.00 - 11.59
        case 720...1019: return .afternoon // 12.00 - 16:59
        case 1020...1259: return .evening // 17.00 - 20:59
        default:
            return .night // 21.00 - 23:59 || 00.00 - 04.59
        }
    }
    
    // Instant changes everytime local time changes
    static func nextBoundary(after date: Date, calendar: Calendar = .current) -> Date {
        let startOfDay = calendar.startOfDay(for: date)
        let boundaryHM: [(Int, Int)] = [(5, 0), (12, 0), (17, 0), (21, 0)]
        
        let todayBoundaries: [Date] = boundaryHM.compactMap { hour, minute in
            calendar.date(bySettingHour: hour, minute: minute, second: 0, of: startOfDay)
        }.sorted()
        
        if let upcoming = todayBoundaries.first(where: { $0 > date }) {
            return upcoming
        }
        
        // after 21.00, then next boundaries tomorow at 05.00
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: startOfDay),
              let fiveNextDay = calendar.date(bySettingHour: 5, minute: 0, second: 0, of: tomorrow)
        else {
            return date.addingTimeInterval(60) // fallback aman
        }
        return fiveNextDay
    }
}

@Observable
final class DayPhaseScheduler {
    private(set) var phase: DayPhase
    
    private var calendar: Calendar
    private let timerLock = NSLock()
    private weak var timerHolder: Timer?
    
    init(calendar: Calendar = .current) {
        self.calendar = calendar
        self.phase = DayPhase.phase(for: Date(), calendar: calendar)
        scheduleNextBoundary()
    }
    
    deinit {
        invalidateTimer()
    }
    
    func refreshFromSystemClock() {
        phase = DayPhase.phase(for: Date(), calendar: calendar)
        invalidateTimer()
        scheduleNextBoundary()
    }
    
    private func invalidateTimer() {
        timerLock.lock()
        timerHolder?.invalidate()
        timerHolder = nil
        timerLock.unlock()
    }
    
    private func scheduleNextBoundary() {
        let now = Date()
        let next = DayPhase.nextBoundary(after: now, calendar: calendar)
        let delay = max(next.timeIntervalSince(now), 0.25)
        
        let timer = Timer(fire: Date().addingTimeInterval(delay), interval: 0, repeats: false) { [weak self] _ in
            guard let self else { return }
            DispatchQueue.main.async {
                self.phase = DayPhase.phase(for: Date(), calendar: self.calendar)
                self.scheduleNextBoundary()
            }
        }
        
        RunLoop.main.add(timer, forMode: .common)
        
        timerLock.lock()
        timerHolder = timer
        timerLock.unlock()
    }
}
