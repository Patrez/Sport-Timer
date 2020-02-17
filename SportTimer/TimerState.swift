//
//  TimerState.swift
//  SportTimer
//
//  Created by Patrik Potocek on 15/02/2020.
//

import Foundation

struct Display {
    var info, countdown, button: String
}

struct TimerState: Codable {
    enum State: String, Codable {
        case initial, onRound, onBreak, end
    }
    
    let roundCount, roundTime, breakTime: Int
    var currentRound: Int
    var closestEnd, pausedTime: Date?
    var state: State

    var roundInterval: TimeInterval {
        return TimeInterval(roundTime)
    }

    var breakInterval: TimeInterval {
        return TimeInterval(breakTime)
    }

    static var `default`: TimerState {
        return TimerState(roundCount: 3, roundTime: 60, breakTime: 60, currentRound: 1, closestEnd: nil, pausedTime: nil, state: .initial)
    }

    var display: Display {
        return Display(info: infoText, countdown: countdown, button: buttonText)
    }

    var infoText: String {
        switch state {
        case .initial, .onRound:
            return "Kolo: \(currentRound) / \(roundCount)"
        case .onBreak:
            return "Prestávka pred \(currentRound). kolom."
        case .end:
            return ""
        }
    }

    var countdown: String {
        switch state {
        case .initial, .onRound, .onBreak:
            let now = Date().clearedNanoseconds
            let endTime = closestEnd ?? now.addingTimeInterval(TimeInterval(roundTime))
            return coundown(from: now, to: endTime) ?? ""
        case .end:
            return "KONIEC"
        }
    }

    var buttonText: String {
        guard pausedTime == nil else {
            return "POKRAČOVAŤ"
        }
        switch state {
        case .initial:
            return "ŠTART"
        case .onRound, .onBreak:
            return "PAUZA"
        case .end:
            return "REŠTART"
        }
    }

    private func coundown(from date1: Date, to date2: Date) -> String? {
        guard date2.timeIntervalSince(date1) >= 0 else {
            return nil
        }
        return TimeFormatters.countdown.string(from: date1, to: date2)
    }
}
